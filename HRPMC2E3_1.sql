--------------------------------------------------------
--  DDL for Package Body HRPMC2E3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPMC2E3" is
-- last update: 07/8/2018 11:40
  function get_numappl(p_codempid varchar2) return varchar2 is
    v_numappl   temploy1.numappl%type;
  begin
    begin
      select  nvl(numappl,codempid)
      into    v_numappl
      from    temploy1
      where   codempid = p_codempid;
    exception when no_data_found then
      v_numappl := p_codempid;
    end;
    return v_numappl;
  end; -- end get_numappl
  --
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    param_flgwarn       := hcm_util.get_string_t(json_obj,'flgwarning');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

    p_codempid_query    := hcm_util.get_string_t(json_obj,'p_codempid_query');

    begin
      select  codcomp
      into    work_codcomp
      from    temploy1
      where   codempid    = p_codempid_query;
    exception when no_data_found then
      null;
    end;
  end; -- end initial_value
  --
  procedure initial_tab_spouse(json_spouse json_object_t) is
  begin
    spouse_codempidsp        := hcm_util.get_string_t(json_spouse,'codempidsp');
    spouse_namimgsp          := hcm_util.get_string_t(json_spouse,'namimgsp');
    spouse_codtitle          := hcm_util.get_string_t(json_spouse,'codtitle');
    spouse_namfirste         := hcm_util.get_string_t(json_spouse,'namfirste');
    spouse_namfirstt         := hcm_util.get_string_t(json_spouse,'namfirstt');
    spouse_namfirst3         := hcm_util.get_string_t(json_spouse,'namfirst3');
    spouse_namfirst4         := hcm_util.get_string_t(json_spouse,'namfirst4');
    spouse_namfirst5         := hcm_util.get_string_t(json_spouse,'namfirst5');
    spouse_namlaste          := hcm_util.get_string_t(json_spouse,'namlaste');
    spouse_namlastt          := hcm_util.get_string_t(json_spouse,'namlastt');
    spouse_namlast3          := hcm_util.get_string_t(json_spouse,'namlast3');
    spouse_namlast4          := hcm_util.get_string_t(json_spouse,'namlast4');
    spouse_namlast5          := hcm_util.get_string_t(json_spouse,'namlast5');
    spouse_numoffid          := hcm_util.get_string_t(json_spouse,'numoffid');
    spouse_dtespbd           := to_date(hcm_util.get_string_t(json_spouse,'dtespbd'),'dd/mm/yyyy');
    spouse_stalife           := hcm_util.get_string_t(json_spouse,'stalife');
    spouse_dtedthsp          := to_date(hcm_util.get_string_t(json_spouse,'dtedthsp'),'dd/mm/yyyy');
    spouse_staincom          := hcm_util.get_string_t(json_spouse,'staincom');
    spouse_desnoffi          := hcm_util.get_string_t(json_spouse,'desnoffi');
    spouse_codspocc          := hcm_util.get_string_t(json_spouse,'codspocc');
    spouse_numfasp           := hcm_util.get_string_t(json_spouse,'numfasp');
    spouse_nummosp           := hcm_util.get_string_t(json_spouse,'nummosp');
    spouse_dtemarry          := to_date(hcm_util.get_string_t(json_spouse,'dtemarry'),'dd/mm/yyyy');
    spouse_codsppro          := hcm_util.get_string_t(json_spouse,'codsppro');
    spouse_codspcty          := hcm_util.get_string_t(json_spouse,'codspcty');
    spouse_desplreg          := hcm_util.get_string_t(json_spouse,'desplreg');
    spouse_desnote           := hcm_util.get_string_t(json_spouse,'desnote');
    spouse_filename          := hcm_util.get_string_t(json_spouse,'filename');
    spouse_flg               := hcm_util.get_string_t(json_spouse,'flg');
  end; -- end initial_tab_spouse
  --
  procedure initial_tab_children(json_children json_object_t) is
    json_children_row    json_object_t;
  begin
    for i in 0..json_children.get_size-1 loop
      json_children_row                   := hcm_util.get_json_t(json_children,to_char(i));
      p_flg_del_children(i+1)             := hcm_util.get_string_t(json_children_row,'flg');
      children_tab(i+1).numseq            := hcm_util.get_string_t(json_children_row,'numseq');
      children_tab(i+1).codtitle          := hcm_util.get_string_t(json_children_row,'codtitle');
      children_tab(i+1).namfirste         := hcm_util.get_string_t(json_children_row,'namfirste');
      children_tab(i+1).namfirstt         := hcm_util.get_string_t(json_children_row,'namfirstt');
      children_tab(i+1).namfirst3         := hcm_util.get_string_t(json_children_row,'namfirst3');
      children_tab(i+1).namfirst4         := hcm_util.get_string_t(json_children_row,'namfirst4');
      children_tab(i+1).namfirst5         := hcm_util.get_string_t(json_children_row,'namfirst5');
      children_tab(i+1).namlaste          := hcm_util.get_string_t(json_children_row,'namlaste');
      children_tab(i+1).namlastt          := hcm_util.get_string_t(json_children_row,'namlastt');
      children_tab(i+1).namlast3          := hcm_util.get_string_t(json_children_row,'namlast3');
      children_tab(i+1).namlast4          := hcm_util.get_string_t(json_children_row,'namlast4');
      children_tab(i+1).namlast5          := hcm_util.get_string_t(json_children_row,'namlast5');
      children_tab(i+1).numoffid          := hcm_util.get_string_t(json_children_row,'numoffid');
      children_tab(i+1).dtechbd           := to_date(hcm_util.get_string_t(json_children_row,'dtechbd'),'dd/mm/yyyy');
      children_tab(i+1).codsex            := hcm_util.get_string_t(json_children_row,'codsex');
      children_tab(i+1).codedlv           := hcm_util.get_string_t(json_children_row,'codedlv');
      children_tab(i+1).stachld           := hcm_util.get_string_t(json_children_row,'stachld');
      children_tab(i+1).stalife           := hcm_util.get_string_t(json_children_row,'stalife');
      children_tab(i+1).dtedthch          := to_date(hcm_util.get_string_t(json_children_row,'dtedthch'),'dd/mm/yyyy');
      children_tab(i+1).flginc            := hcm_util.get_string_t(json_children_row,'flginc');
      children_tab(i+1).flgedlv           := hcm_util.get_string_t(json_children_row,'flgedlv');
      children_tab(i+1).flgdeduct         := hcm_util.get_string_t(json_children_row,'flgdeduct');
      children_tab(i+1).stabf             := hcm_util.get_string_t(json_children_row,'stabf');
      children_tab(i+1).filename          := hcm_util.get_string_t(json_children_row,'filename');
    end loop;
  end; -- end initial_tab_children
  --
  procedure initial_tab_father_mother(json_father_mother json_object_t) is
  begin
    famo_codempfa          := hcm_util.get_string_t(json_father_mother,'codempfa');
    famo_codtitlf          := hcm_util.get_string_t(json_father_mother,'codtitlf');
    famo_namfstfe          := hcm_util.get_string_t(json_father_mother,'namfstfe');
    famo_namfstft          := hcm_util.get_string_t(json_father_mother,'namfstft');
    famo_namfstf3          := hcm_util.get_string_t(json_father_mother,'namfstf3');
    famo_namfstf4          := hcm_util.get_string_t(json_father_mother,'namfstf4');
    famo_namfstf5          := hcm_util.get_string_t(json_father_mother,'namfstf5');
    famo_namlstfe          := hcm_util.get_string_t(json_father_mother,'namlstfe');
    famo_namlstft          := hcm_util.get_string_t(json_father_mother,'namlstft');
    famo_namlstf3          := hcm_util.get_string_t(json_father_mother,'namlstf3');
    famo_namlstf4          := hcm_util.get_string_t(json_father_mother,'namlstf4');
    famo_namlstf5          := hcm_util.get_string_t(json_father_mother,'namlstf5');
    famo_numofidf          := hcm_util.get_string_t(json_father_mother,'numofidf');
    famo_dtebdfa           := to_date(hcm_util.get_string_t(json_father_mother,'dtebdfa'),'dd/mm/yyyy');
    famo_codfnatn          := hcm_util.get_string_t(json_father_mother,'codfnatn');
    famo_codfrelg          := hcm_util.get_string_t(json_father_mother,'codfrelg');
    famo_codfoccu          := hcm_util.get_string_t(json_father_mother,'codfoccu');
    famo_staliff           := hcm_util.get_string_t(json_father_mother,'staliff');
    famo_dtedeathf         := to_date(hcm_util.get_string_t(json_father_mother,'dtedeathf'),'dd/mm/yyyy');
    famo_filenamf          := hcm_util.get_string_t(json_father_mother,'filenamf');
    famo_codempmo          := hcm_util.get_string_t(json_father_mother,'codempmo');
    famo_codtitlm          := hcm_util.get_string_t(json_father_mother,'codtitlm');
    famo_namfstme          := hcm_util.get_string_t(json_father_mother,'namfstme');
    famo_namfstmt          := hcm_util.get_string_t(json_father_mother,'namfstmt');
    famo_namfstm3          := hcm_util.get_string_t(json_father_mother,'namfstm3');
    famo_namfstm4          := hcm_util.get_string_t(json_father_mother,'namfstm4');
    famo_namfstm5          := hcm_util.get_string_t(json_father_mother,'namfstm5');
    famo_namlstme          := hcm_util.get_string_t(json_father_mother,'namlstme');
    famo_namlstmt          := hcm_util.get_string_t(json_father_mother,'namlstmt');
    famo_namlstm3          := hcm_util.get_string_t(json_father_mother,'namlstm3');
    famo_namlstm4          := hcm_util.get_string_t(json_father_mother,'namlstm4');
    famo_namlstm5          := hcm_util.get_string_t(json_father_mother,'namlstm5');
    famo_numofidm          := hcm_util.get_string_t(json_father_mother,'numofidm');
    famo_dtebdmo           := to_date(hcm_util.get_string_t(json_father_mother,'dtebdmo'),'dd/mm/yyyy');
    famo_codmnatn          := hcm_util.get_string_t(json_father_mother,'codmnatn');
    famo_codmrelg          := hcm_util.get_string_t(json_father_mother,'codmrelg');
    famo_codmoccu          := hcm_util.get_string_t(json_father_mother,'codmoccu');
    famo_stalifm           := hcm_util.get_string_t(json_father_mother,'stalifm');
    famo_dtedeathm         := to_date(hcm_util.get_string_t(json_father_mother,'dtedeathm'),'dd/mm/yyyy');
    famo_filenamm          := hcm_util.get_string_t(json_father_mother,'filenamm');
    famo_codtitlc          := hcm_util.get_string_t(json_father_mother,'codtitlc');
    famo_namfstce          := hcm_util.get_string_t(json_father_mother,'namfstce');
    famo_namfstct          := hcm_util.get_string_t(json_father_mother,'namfstct');
    famo_namfstc3          := hcm_util.get_string_t(json_father_mother,'namfstc3');
    famo_namfstc4          := hcm_util.get_string_t(json_father_mother,'namfstc4');
    famo_namfstc5          := hcm_util.get_string_t(json_father_mother,'namfstc5');
    famo_namlstce          := hcm_util.get_string_t(json_father_mother,'namlstce');
    famo_namlstct          := hcm_util.get_string_t(json_father_mother,'namlstct');
    famo_namlstc3          := hcm_util.get_string_t(json_father_mother,'namlstc3');
    famo_namlstc4          := hcm_util.get_string_t(json_father_mother,'namlstc4');
    famo_namlstc5          := hcm_util.get_string_t(json_father_mother,'namlstc5');
    famo_adrcont1          := hcm_util.get_string_t(json_father_mother,'adrcont1');
    famo_codpost           := hcm_util.get_string_t(json_father_mother,'codpost');
    famo_numtele           := hcm_util.get_string_t(json_father_mother,'numtele');
    famo_numfax            := hcm_util.get_string_t(json_father_mother,'numfax');
    famo_email             := hcm_util.get_string_t(json_father_mother,'email');
    famo_desrelat          := hcm_util.get_string_t(json_father_mother,'desrelat');
    famo_flg               := hcm_util.get_string_t(json_father_mother,'flg');
  end; -- end initial_tab_father_mother
  --
  procedure initial_tab_relatives(json_relatives json_object_t) is
    json_relatives_row    json_object_t;
  begin
    for i in 0..json_relatives.get_size-1 loop
      json_relatives_row                    := hcm_util.get_json_t(json_relatives,to_char(i));
      p_flg_del_relatives(i+1)              := hcm_util.get_string_t(json_relatives_row,'flg');
      relatives_tab(i+1).numseq             := hcm_util.get_string_t(json_relatives_row,'numseq');
      relatives_tab(i+1).codemprl           := hcm_util.get_string_t(json_relatives_row,'codemprl');
      relatives_tab(i+1).namrele            := hcm_util.get_string_t(json_relatives_row,'namrele');
      relatives_tab(i+1).namrelt            := hcm_util.get_string_t(json_relatives_row,'namrelt');
      relatives_tab(i+1).namrel3            := hcm_util.get_string_t(json_relatives_row,'namrel3');
      relatives_tab(i+1).namrel4            := hcm_util.get_string_t(json_relatives_row,'namrel4');
      relatives_tab(i+1).namrel5            := hcm_util.get_string_t(json_relatives_row,'namrel5');
      relatives_tab(i+1).numtelec           := hcm_util.get_string_t(json_relatives_row,'numtelec');
      relatives_tab(i+1).adrcomt            := hcm_util.get_string_t(json_relatives_row,'adrcomt');
    end loop;
  end; -- end initial_tab_relatives
  --
  function check_emp_status return varchar2 is
    v_status    varchar2(100);
  begin
    begin
      select  'UPDATE'
      into    v_status
      from    temploy1
      where   codempid = p_codempid_query;
    exception when no_data_found then
      v_status  := 'INSERT';
    end;
    return v_status;
  end;
  --
  procedure check_tab_spouse is
    v_code      varchar2(100);
  begin
    if spouse_codempidsp is not null then
      begin
        select codempid into v_code
        from	 temploy1
        where	 codempid   = spouse_codempidsp;
      exception when no_data_found then
        spouse_codempidsp   := null;
      end;
    end if;

    if spouse_codspocc is not null then
      begin
        select codcodec into v_code
        from	 tcodoccu
        where	 codcodec   = spouse_codspocc;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODOCCU');
        return;
      end;
    end if;

    if spouse_codsppro is not null then
      begin
        select codcodec into v_code
        from	 tcodprov
        where	 codcodec   = spouse_codsppro;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODPROV');
        return;
      end;
    end if;

    if spouse_codspcty is not null then
      begin
        select codcodec into v_code
        from	 tcodcnty
        where	 codcodec   = spouse_codspcty;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODCNTY');
        return;
      end;
    end if;
  end; -- end check_tab_spouse
  --
  procedure check_tab_children(json_str_input in clob) is
    v_str_json      json_object_t;
    v_code          varchar2(100);
    v_codedlv       tchildrn.codedlv%type;
  begin
    v_str_json      := json_object_t(json_str_input);
    v_codedlv       := hcm_util.get_string_t(v_str_json,'codedlv');
    if v_codedlv is not null then
      begin
        select  codcodec
        into    v_code
        from    tcodeduc
        where   codcodec = v_codedlv;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEDUC');
        return;
      end;
    end if;
  end; -- end check_tab_children
  --
  procedure check_tab_famo is
    v_code          varchar2(100);
    v_ch            boolean;
    v_ctrl_codnatnl tsetdeflt.defaultval%type;
  begin
    begin
      select  defaultval
      into    v_ctrl_codnatnl
      from    tsetdeflt
      where   codapp    = 'HRPMC2E'
      and     numpage   = 'HRPMC2E11'
      and     fieldname = 'CODNATNL'
      and     seqno     = 1;
    exception when no_data_found then
      null;
    end;
    if famo_codempfa is not null then
      begin
        select codempid into v_code
        from	 temploy1
        where	 codempid   = famo_codempfa;
      exception when no_data_found then
        famo_codempfa   := null;
      end;
    end if;

    if famo_codfnatn is not null then
      begin
        select codcodec into v_code
        from	 tcodnatn
        where	 codcodec   = famo_codfnatn;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODNATN');
        return;
      end;
    end if;

    if famo_numofidf is not null and param_flgwarn = 'S' then
      if v_ctrl_codnatnl = famo_codfnatn then
        v_ch := check_numoffid(famo_numofidf);
        if not v_ch then -- Start check warning
          param_msg_error := get_error_msg_php('PM0059',global_v_lang,'','numofidf');
          param_flgwarn   := 'WARN1';
          return;
        end if;
      end if;
    end if;
    if param_flgwarn = 'S' then
      param_flgwarn   := 'WARN1';
    end if;

    if famo_codfrelg is not null then
      begin
        select codcodec into v_code
        from	 tcodreli
        where	 codcodec   = famo_codfrelg;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODRELI');
        return;
      end;
    end if;

    if famo_codfoccu is not null then
      begin
        select codcodec into v_code
        from	 tcodoccu
        where	 codcodec   = famo_codfoccu;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODOCCU');
        return;
      end;
    end if;

    if famo_codempmo is not null then
      begin
        select codempid into v_code
        from	 temploy1
        where	 codempid   = famo_codempmo;
      exception when no_data_found then
        famo_codempmo   := null;
      end;
    end if;

    if famo_codmnatn is not null then
      begin
        select codcodec into v_code
        from	 tcodnatn
        where	 codcodec   = famo_codmnatn;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODNATN');
        return;
      end;
    end if;
    if param_flgwarn = 'WARN1' then
      if famo_numofidm is not null then
        if v_ctrl_codnatnl = famo_codmnatn then
          v_ch := check_numoffid(famo_numofidm);
          if not v_ch then -- Start check warning
            param_msg_error := get_error_msg_php('PM0059',global_v_lang,'','numofidm');
            param_flgwarn   := 'WARN2';
            return;
          end if;
        end if;
      end if;
    end if;
    param_flgwarn := '';

    if famo_codmrelg is not null then
      begin
        select codcodec into v_code
        from	 tcodreli
        where	 codcodec   = famo_codmrelg;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODRELI');
        return;
      end;
    end if;

    if famo_codmoccu is not null then
      begin
        select codcodec into v_code
        from	 tcodoccu
        where	 codcodec   = famo_codmoccu;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODOCCU');
        return;
      end;
    end if;
  end; -- end check_tabfa_mo
  --
  function check_codempid(p_codempid_rel varchar2) return varchar2 is
    v_code          varchar2(100);
  begin
    if p_codempid_rel is not null then
      begin
        select  codempid
        into    v_code
        from    temploy1
        where   codempid  = p_codempid_rel;
      exception when no_data_found then
        v_code  := '';
      end;
    end if;
    return v_code;
  end; -- end check_codempid
  --
  function get_desciption (p_table in varchar2,p_field in varchar2,p_code in varchar2) return varchar2 is
    v_desc     varchar2(500):= p_code;
    v_stament  varchar2(500);
    v_funcdesc varchar2(500);
    v_data_type varchar2(500);
  begin
    if p_code is null then
      return v_desc ;
    end if;

    begin
      select  funcdesc,data_type
      into    v_funcdesc,v_data_type
      from    tcoldesc
      where   codtable  = p_table
      and     codcolmn  = p_field
      and     rownum    = 1 ;
    exception when no_data_found then
       v_funcdesc := null;
    end ;

    if v_funcdesc is not null   then
      v_stament   := 'select '||v_funcdesc||'from dual' ;
      v_stament   := replace(v_stament,'P_CODE',''''||p_code||'''') ;
      v_stament   := replace(v_stament,'P_LANG',global_v_lang) ;
      return execute_desc (v_stament) ;
    else
      if v_data_type = 'DATE' then
        return hcm_util.get_date_buddhist_era(to_date(v_desc,'dd/mm/yyyy'));
      elsif p_field in ('STAYEAR','DTEGYEAR') then
        return v_desc + global_v_zyear;
      else
        return v_desc ;
      end if;
    end if;
  end; -- end get_desciption
  --
  procedure upd_log1
    (p_codtable	in varchar2,
     p_numpage 	in varchar2,
     p_fldedit 	in varchar2,
     p_typdata 	in varchar2,
     p_desold 	in varchar2,
     p_desnew 	in varchar2,
     p_flgenc 	in varchar2,
     p_upd	    in out boolean,
     p_codempid in varchar2 default '') is

     v_exist		 boolean := false;
     v_datenew 	 date;
     v_dateold 	 date;
     v_desnew 	 varchar2(500 char) ;
     v_desold 	 varchar2(500 char) ;
     v_codempid  temploy1.codempid%type;

    cursor c_ttemlog1 is
      select rowid
      from   ttemlog1
      where  codempid = v_codempid
      and		 dteedit	= sysdate
      and		 numpage	= p_numpage
      and    fldedit  = upper(p_fldedit);
  begin
    v_codempid  := nvl(p_codempid,p_codempid_query);
    if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
       v_desnew := p_desnew ;
       v_desold := p_desold ;
       if  p_typdata = 'D' then
           if  p_desnew is not null and global_v_zyear = 543 then
               v_datenew := add_months(to_date(v_desnew,'dd/mm/yyyy'),-(543*12));
               v_desnew  := to_char(v_datenew,'dd/mm/yyyy') ;
           end if;
           if  p_desold is not null and global_v_zyear = 543 then
               v_dateold := add_months(to_date(v_desold,'dd/mm/yyyy'),-(543*12));
               v_desold  := to_char(v_dateold,'dd/mm/yyyy') ;
           end if;
       end if;
--      if :parameter.codapp in ('PMC2','RECRUIT') then sssssssssssssssssssssssssssssss
        p_upd := true;
        for r_ttemlog1 in c_ttemlog1 loop
          v_exist := true;
          update ttemlog1
          set    codcomp 	= work_codcomp,
                 desold 	= v_desold,
                 desnew 	= v_desnew,
                 flgenc 	= p_flgenc,
                 codtable = upper(p_codtable),
                 dteupd 	= trunc(sysdate),
                 coduser 	= global_v_coduser
          where  rowid = r_ttemlog1.rowid;
        end loop;
        if not v_exist then
          insert into  ttemlog1
            (codempid,dteedit,numpage,fldedit,codcomp,
             desold,desnew,flgenc,codtable,dteupd,coduser)
          values
            (v_codempid,sysdate,p_numpage,upper(p_fldedit),work_codcomp,
             v_desold,v_desnew,p_flgenc,upper(p_codtable),trunc(sysdate),global_v_coduser);
        end if;
    end if;
  end; -- end upd_log1
  --
  procedure upd_log2
    (p_codtable	in varchar2,
     p_numpage 	in varchar2,
     p_numseq		in number,
     p_fldedit 	in varchar2,
     p_typkey 	in varchar2,
     p_fldkey 	in varchar2,
     p_codseq 	in varchar2,
     p_dteseq 	in date,
     p_typdata 	in varchar2,
     p_desold 	in varchar2,
     p_desnew 	in varchar2,
     p_flgenc 	in varchar2,
     p_upd	in out boolean) is
    v_exist		boolean := false;
     v_datenew 	 date;
     v_dateold 	 date;
     v_desnew 	 varchar2(500 char) ;
     v_desold 	 varchar2(500 char) ;

  cursor c_ttemlog2 is
    select rowid
    from   ttemlog2
    where  codempid = p_codempid_query
    and		 dteedit	= sysdate
    and		 numpage	= p_numpage
    and		 numseq 	= p_numseq
    and    fldedit  = upper(p_fldedit);
  begin
    if check_emp_status = 'INSERT' then--and:parameter.codapp <> 'REHIRE'
      p_upd := true;--Modify 10/07/2551
      return;
    end if;
    if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
       v_desnew := p_desnew ;
       v_desold := p_desold ;
       if  p_typdata = 'D' then
           if  p_desnew is not null and global_v_zyear = 543 then
               v_datenew := add_months(to_date(v_desnew,'dd/mm/yyyy'),-(543*12));
               v_desnew  := to_char(v_datenew,'dd/mm/yyyy') ;
           end if;
           if  p_desold is not null and global_v_zyear = 543 then
               v_dateold := add_months(to_date(v_desold,'dd/mm/yyyy'),-(543*12));
               v_desold  := to_char(v_dateold,'dd/mm/yyyy') ;
           end if;
       end if;

--      if :parameter.codapp in('PMC2','RECRUIT') then
        p_upd := true;
        for r_ttemlog2 in c_ttemlog2 loop
          v_exist := true;
          update ttemlog2
          set    typkey = p_typkey,
                 fldkey = upper(p_fldkey),
                 codseq = p_codseq,
                 dteseq = p_dteseq,
                 codcomp = work_codcomp,
                 desold = v_desold,
                 desnew = v_desnew,
                 flgenc = p_flgenc,
                 codtable = upper(p_codtable),
                 coduser = global_v_coduser,
                 codcreate = global_v_coduser
          where  rowid = r_ttemlog2.rowid;
        end loop;
        if not v_exist then
          insert into  ttemlog2
            (codempid,dteedit,numpage,numseq,fldedit,codcomp,
             typkey,fldkey,codseq,dteseq,
             desold,desnew,flgenc,codtable,codcreate,coduser)
          values
            (p_codempid_query,sysdate,p_numpage,p_numseq,upper(p_fldedit),work_codcomp,
             p_typkey,p_fldkey,p_codseq,p_dteseq,
             v_desold,v_desnew,p_flgenc,upper(p_codtable),global_v_coduser,global_v_coduser);
        end if;
--      end if;
    end if;
  end; -- end upd_log2
  --
  procedure upd_log3
    (p_codtable	  in varchar2,
     p_numpage 	  in varchar2,
     p_typdeduct 	in varchar2,
     p_coddeduct 	in varchar2,
     p_desold 	  in varchar2,
     p_desnew 	  in varchar2,
     p_upd	      in out boolean) is

    v_exist		boolean := false;

  cursor c_ttemlog3 is
    select rowid
    from   ttemlog3
    where  codempid  = p_codempid_query
    and		 dteedit	 = sysdate
    and		 numpage	 = p_numpage
    and    typdeduct = p_typdeduct
    and    coddeduct = p_coddeduct;
  begin
    if check_emp_status = 'INSERT' then
      p_upd := true; --Modify 10/07/2551
      return;
    end if;
    if (p_desold is null and p_desnew is not null) or
       (p_desold is not null and p_desnew is null) or
       (p_desold <> p_desnew) then
--      if :parameter.codapp in('PMC2','RECRUIT') then
        p_upd := true;
        for r_ttemlog3 in c_ttemlog3 loop
          v_exist := true;
          update ttemlog3
          set    codcomp = work_codcomp,
                 desold = p_desold,
                 desnew = p_desnew,
                 codtable = upper(p_codtable),
                 codcreate = global_v_coduser,
                 coduser = global_v_coduser
          where  rowid = r_ttemlog3.rowid;
        end loop;
        if not v_exist then
          insert into  ttemlog3
            (codempid,dteedit,numpage,typdeduct,coddeduct,
             codcomp,desold,desnew,codtable,codcreate,coduser)
          values
            (p_codempid_query,sysdate,p_numpage,p_typdeduct,p_coddeduct,
             work_codcomp,p_desold,p_desnew,upper(p_codtable),global_v_coduser,global_v_coduser);
        end if;
--      end if;
    end if;
  end; -- end upd_log3
  --
  procedure update_emp_spouse is
    v_upd					  boolean := false;
    v_check_spouse  varchar2(1) := 'N';
    v_numrefdoc     tappldoc.numrefdoc%type;
    cursor c1 is
      select  t1.codtitle,t1.namfirste,t1.namfirstt,t1.namfirst3,t1.namfirst4,t1.namfirst5,
              t1.namlaste,t1.namlastt,t1.namlast3,t1.namlast4,t1.namlast5,
              t1.namempe,t1.namempt,t1.namemp3,t1.namemp4,t1.namemp5,
              t2.numoffid,t1.dteempdb as dtespbd,'Y' as stalife,'' as dtedthsp,'Y' as staincom,
              get_tcompny_name(hcm_util.get_codcomp_level(t1.codcomp,1),global_v_lang) as desnoffi,
              '' as codspocc,t3.numofidf as numfasp,t3.numofidm as nummosp,t4.namimage as namimgsp
      from    temploy1 t1
              left join temploy2 t2
              on (t1.codempid = t2.codempid)
              left join tfamily t3
              on (t1.codempid = t3.codempid)
              left join tempimge t4
              on (t1.codempid = t4.codempid)
      where   t1.codempid  = p_codempid_query;
  begin
    begin
      select  'Y'
      into    v_check_spouse
      from    tspouse
      where   codempid    = spouse_codempidsp;
    exception when no_data_found then
      v_check_spouse    := 'N';
    end;
    if spouse_codempidsp is not null and spouse_flg = 'add' and v_check_spouse = 'N' then
      for i in c1 loop
        upd_log1('tspouse','31','codempidsp','C',null,p_codempid_query,'N',v_upd,spouse_codempidsp);
--        upd_log1('tspouse','31','namimgsp','C',null,i.namimgsp,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','codtitle','C',null,i.codtitle,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namfirste','C',null,i.namfirste,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namfirstt','C',null,i.namfirstt,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namfirst3','C',null,i.namfirst3,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namfirst4','C',null,i.namfirst4,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namfirst5','C',null,i.namfirst5,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namlaste','C',null,i.namlaste,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namlastt','C',null,i.namlastt,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namlast3','C',null,i.namlast3,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namlast4','C',null,i.namlast4,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namlast5','C',null,i.namlast5,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namspe','C',null,i.namempe,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namspt','C',null,i.namempt,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namsp3','C',null,i.namemp3,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namsp4','C',null,i.namemp4,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','namsp5','C',null,i.namemp5,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','numoffid','C',null,i.numoffid,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','dtespbd','D',null,to_char(i.dtespbd,'dd/mm/yyyy'),'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','stalife','C',null,i.stalife,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','dtedthsp','D',null,to_char(i.dtedthsp,'dd/mm/yyyy'),'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','staincom','C',null,i.staincom,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','desnoffi','C',null,i.desnoffi,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','codspocc','C',null,i.codspocc,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','numfasp','C',null,i.numfasp,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','nummosp','C',null,i.nummosp,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','dtemarry','D',null,to_char(spouse_dtemarry,'dd/mm/yyyy'),'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','codsppro','C',null,spouse_codsppro,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','codspcty','C',null,spouse_codspcty,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','desplreg','C',null,spouse_desplreg,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','desnote','C',null,spouse_desnote,'N',v_upd,spouse_codempidsp);
        upd_log1('tspouse','31','filename','C',null,spouse_filename,'N',v_upd,spouse_codempidsp);
        --- insert tappldoc ---
        hrpmc2e.update_filedoc( spouse_codempidsp,
                                spouse_filename,
                                GET_LABEL_NAME('HRPMC2E3T1',global_v_lang,20),
                                '0002',--- type doc spouse
                                global_v_coduser,
                                v_numrefdoc);
        -----------------------
        insert into tspouse(codempid,codempidsp,/*namimgsp,*/codtitle,
                            namspe,namspt,namsp3,namsp4,namsp5,
                            namfirste,namfirstt,namfirst3,
                            namfirst4,namfirst5,namlaste,namlastt,namlast3,namlast4,
                            namlast5,numoffid,dtespbd,stalife,dtedthsp,staincom,
                            desnoffi,codspocc,numfasp,nummosp,dtemarry,codsppro,
                            codspcty,desplreg,desnote,filename,numrefdoc,codcreate,coduser)
        values (spouse_codempidsp,p_codempid_query,/*i.namimgsp,*/i.codtitle,
                i.namempe,i.namempt,i.namemp3,i.namemp4,i.namemp5,
                i.namfirste,i.namfirstt,i.namfirst3,
                i.namfirst4,i.namfirst5,i.namlaste,i.namlastt,i.namlast3,i.namlast4,
                i.namlast5,i.numoffid,i.dtespbd,i.stalife,i.dtedthsp,i.staincom,
                i.desnoffi,i.codspocc,i.numfasp,i.nummosp,spouse_dtemarry,spouse_codsppro,
                spouse_codspcty,spouse_desplreg,spouse_desnote,spouse_filename,v_numrefdoc,global_v_coduser,global_v_coduser);
      end loop;
    end if;
  end; -- end update_emp_spouse
  --
  procedure save_spouse is
    v_exist				boolean := false;
    v_upd					boolean := false;

    cursor c_tspouse is
      select  codempid,codempidsp,namimgsp,codtitle,
              namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
              namlaste,namlastt,namlast3,namlast4,namlast5,
              namspe,namspt,namsp3,namsp4,namsp5,
              numoffid,dtespbd,
              stalife,dtedthsp,staincom,desnoffi,codspocc,
              numfasp,nummosp,dtemarry,codsppro,codspcty,
              desplreg,desnote,filename,numrefdoc,rowid
      from    tspouse
      where   codempid = p_codempid_query;

    v_namspe        tspouse.namspe%type;
    v_namspt        tspouse.namspe%type;
    v_namsp3        tspouse.namspe%type;
    v_namsp4        tspouse.namspe%type;
    v_namsp5        tspouse.namspe%type;

    v_numrefdoc     tappldoc.numrefdoc%type;
  begin
    v_namspe	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',spouse_codtitle,'101')))||
                       ltrim(rtrim(spouse_namfirste))||' '||ltrim(rtrim(spouse_namlaste)),1,100);
    v_namspt	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',spouse_codtitle,'102')))||
                       ltrim(rtrim(spouse_namfirstt))||' '||ltrim(rtrim(spouse_namlastt)),1,100);
    v_namsp3	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',spouse_codtitle,'103')))||
                       ltrim(rtrim(spouse_namfirst3))||' '||ltrim(rtrim(spouse_namlast3)),1,100);
    v_namsp4	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',spouse_codtitle,'104')))||
                       ltrim(rtrim(spouse_namfirst4))||' '||ltrim(rtrim(spouse_namlast4)),1,100);
    v_namsp5	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',spouse_codtitle,'105')))||
                       ltrim(rtrim(spouse_namfirst5))||' '||ltrim(rtrim(spouse_namlast5)),1,100);
    for i in c_tspouse loop
      v_exist       := true;
      v_numrefdoc   := i.numrefdoc;
      upd_log1('tspouse','31','codempidsp','C',i.codempidsp,spouse_codempidsp,'N',v_upd);
      upd_log1('tspouse','31','namimgsp','C',i.namimgsp,spouse_namimgsp,'N',v_upd);
      upd_log1('tspouse','31','codtitle','C',i.codtitle,spouse_codtitle,'N',v_upd);
      upd_log1('tspouse','31','namfirste','C',i.namfirste,spouse_namfirste,'N',v_upd);
      upd_log1('tspouse','31','namfirstt','C',i.namfirstt,spouse_namfirstt,'N',v_upd);
      upd_log1('tspouse','31','namfirst3','C',i.namfirst3,spouse_namfirst3,'N',v_upd);
      upd_log1('tspouse','31','namfirst4','C',i.namfirst4,spouse_namfirst4,'N',v_upd);
      upd_log1('tspouse','31','namfirst5','C',i.namfirst5,spouse_namfirst5,'N',v_upd);
      upd_log1('tspouse','31','namlaste','C',i.namlaste,spouse_namlaste,'N',v_upd);
      upd_log1('tspouse','31','namlastt','C',i.namlastt,spouse_namlastt,'N',v_upd);
      upd_log1('tspouse','31','namlast3','C',i.namlast3,spouse_namlast3,'N',v_upd);
      upd_log1('tspouse','31','namlast4','C',i.namlast4,spouse_namlast4,'N',v_upd);
      upd_log1('tspouse','31','namlast5','C',i.namlast5,spouse_namlast5,'N',v_upd);
      upd_log1('tspouse','31','namspe','C',i.namspe,v_namspe,'N',v_upd);
      upd_log1('tspouse','31','namspt','C',i.namspt,v_namspt,'N',v_upd);
      upd_log1('tspouse','31','namsp3','C',i.namsp3,v_namsp3,'N',v_upd);
      upd_log1('tspouse','31','namsp4','C',i.namsp4,v_namsp4,'N',v_upd);
      upd_log1('tspouse','31','namsp5','C',i.namsp5,v_namsp5,'N',v_upd);
      upd_log1('tspouse','31','numoffid','C',i.numoffid,spouse_numoffid,'N',v_upd);
      upd_log1('tspouse','31','dtespbd','D',to_char(i.dtespbd,'dd/mm/yyyy'),to_char(spouse_dtespbd,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tspouse','31','stalife','C',i.stalife,spouse_stalife,'N',v_upd);
      upd_log1('tspouse','31','dtedthsp','D',to_char(i.dtedthsp,'dd/mm/yyyy'),to_char(spouse_dtedthsp,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tspouse','31','staincom','C',i.staincom,spouse_staincom,'N',v_upd);
      upd_log1('tspouse','31','desnoffi','C',i.desnoffi,spouse_desnoffi,'N',v_upd);
      upd_log1('tspouse','31','codspocc','C',i.codspocc,spouse_codspocc,'N',v_upd);
      upd_log1('tspouse','31','numfasp','C',i.numfasp,spouse_numfasp,'N',v_upd);
      upd_log1('tspouse','31','nummosp','C',i.nummosp,spouse_nummosp,'N',v_upd);
      upd_log1('tspouse','31','dtemarry','D',to_char(i.dtemarry,'dd/mm/yyyy'),to_char(spouse_dtemarry,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tspouse','31','codsppro','C',i.codsppro,spouse_codsppro,'N',v_upd);
      upd_log1('tspouse','31','codspcty','C',i.codspcty,spouse_codspcty,'N',v_upd);
      upd_log1('tspouse','31','desplreg','C',i.desplreg,spouse_desplreg,'N',v_upd);
      upd_log1('tspouse','31','desnote','C',i.desnote,spouse_desnote,'N',v_upd);
      upd_log1('tspouse','31','filename','C',i.filename,spouse_filename,'N',v_upd);
      --- update tappldoc ---
      if nvl(i.filename,'#$@') <> nvl(spouse_filename,'#$@') then
        hrpmc2e.update_filedoc( p_codempid_query,
                                spouse_filename,
                                GET_LABEL_NAME('HRPMC2E3T1',global_v_lang,20),
                                '0002',--- type doc spouse
                                global_v_coduser,
                                v_numrefdoc);
      end if;
      -----------------------
      if v_upd then
        begin
          update tspouse
          set codempidsp = spouse_codempidsp,
              namimgsp = spouse_namimgsp,
              codtitle = spouse_codtitle,
              namspe = v_namspe,
              namspt = v_namspt,
              namsp3 = v_namsp3,
              namsp4 = v_namsp4,
              namsp5 = v_namsp5,
              namfirste = spouse_namfirste,
              namfirstt = spouse_namfirstt,
              namfirst3 = spouse_namfirst3,
              namfirst4 = spouse_namfirst4,
              namfirst5 = spouse_namfirst5,
              namlaste = spouse_namlaste,
              namlastt = spouse_namlastt,
              namlast3 = spouse_namlast3,
              namlast4 = spouse_namlast4,
              namlast5 = spouse_namlast5,
              numoffid = spouse_numoffid,
              dtespbd = spouse_dtespbd,
              stalife = spouse_stalife,
              dtedthsp = spouse_dtedthsp,
              staincom = spouse_staincom,
              desnoffi = spouse_desnoffi,
              codspocc = spouse_codspocc,
              numfasp = spouse_numfasp,
              nummosp = spouse_nummosp,
              dtemarry = spouse_dtemarry,
              codsppro = spouse_codsppro,
              codspcty = spouse_codspcty,
              desplreg = spouse_desplreg,
              desnote = spouse_desnote,
              filename = spouse_filename,
              numrefdoc = v_numrefdoc,
              coduser = global_v_coduser
          where rowid = i.rowid;
        end;
      end if;
    end loop;
    if not v_exist and spouse_flg = 'add' then
      upd_log1('tspouse','31','codempidsp','C',null,spouse_codempidsp,'N',v_upd);
      upd_log1('tspouse','31','namimgsp','C',null,spouse_namimgsp,'N',v_upd);
      upd_log1('tspouse','31','codtitle','C',null,spouse_codtitle,'N',v_upd);
      upd_log1('tspouse','31','namfirste','C',null,spouse_namfirste,'N',v_upd);
      upd_log1('tspouse','31','namfirstt','C',null,spouse_namfirstt,'N',v_upd);
      upd_log1('tspouse','31','namfirst3','C',null,spouse_namfirst3,'N',v_upd);
      upd_log1('tspouse','31','namfirst4','C',null,spouse_namfirst4,'N',v_upd);
      upd_log1('tspouse','31','namfirst5','C',null,spouse_namfirst5,'N',v_upd);
      upd_log1('tspouse','31','namlaste','C',null,spouse_namlaste,'N',v_upd);
      upd_log1('tspouse','31','namlastt','C',null,spouse_namlastt,'N',v_upd);
      upd_log1('tspouse','31','namlast3','C',null,spouse_namlast3,'N',v_upd);
      upd_log1('tspouse','31','namlast4','C',null,spouse_namlast4,'N',v_upd);
      upd_log1('tspouse','31','namlast5','C',null,spouse_namlast5,'N',v_upd);
      upd_log1('tspouse','31','namspe','C',null,v_namspe,'N',v_upd);
      upd_log1('tspouse','31','namspt','C',null,v_namspt,'N',v_upd);
      upd_log1('tspouse','31','namsp3','C',null,v_namsp3,'N',v_upd);
      upd_log1('tspouse','31','namsp4','C',null,v_namsp4,'N',v_upd);
      upd_log1('tspouse','31','namsp5','C',null,v_namsp5,'N',v_upd);
      upd_log1('tspouse','31','numoffid','C',null,spouse_numoffid,'N',v_upd);
      upd_log1('tspouse','31','dtespbd','D',null,to_char(spouse_dtespbd,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tspouse','31','stalife','C',null,spouse_stalife,'N',v_upd);
      upd_log1('tspouse','31','dtedthsp','D',null,to_char(spouse_dtedthsp,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tspouse','31','staincom','C',null,spouse_staincom,'N',v_upd);
      upd_log1('tspouse','31','desnoffi','C',null,spouse_desnoffi,'N',v_upd);
      upd_log1('tspouse','31','codspocc','C',null,spouse_codspocc,'N',v_upd);
      upd_log1('tspouse','31','numfasp','C',null,spouse_numfasp,'N',v_upd);
      upd_log1('tspouse','31','nummosp','C',null,spouse_nummosp,'N',v_upd);
      upd_log1('tspouse','31','dtemarry','D',null,to_char(spouse_dtemarry,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tspouse','31','codsppro','C',null,spouse_codsppro,'N',v_upd);
      upd_log1('tspouse','31','codspcty','C',null,spouse_codspcty,'N',v_upd);
      upd_log1('tspouse','31','desplreg','C',null,spouse_desplreg,'N',v_upd);
      upd_log1('tspouse','31','desnote','C',null,spouse_desnote,'N',v_upd);
      upd_log1('tspouse','31','filename','C',null,spouse_filename,'N',v_upd);

      --- insert tappldoc ---
      hrpmc2e.update_filedoc( p_codempid_query,
                              spouse_filename,
                              GET_LABEL_NAME('HRPMC2E3T1',global_v_lang,20),
                              '0002',--- type doc spouse
                              global_v_coduser,
                              v_numrefdoc);
      -----------------------
      insert into tspouse(codempid,codempidsp,namimgsp,codtitle,
                          namspe,namspt,namsp3,namsp4,namsp5,
                          namfirste,namfirstt,namfirst3,
                          namfirst4,namfirst5,namlaste,namlastt,namlast3,namlast4,
                          namlast5,numoffid,dtespbd,stalife,dtedthsp,staincom,
                          desnoffi,codspocc,numfasp,nummosp,dtemarry,codsppro,
                          codspcty,desplreg,desnote,filename,numrefdoc,codcreate,coduser)
      values (p_codempid_query,spouse_codempidsp,spouse_namimgsp,spouse_codtitle,
              v_namspe,v_namspt,v_namsp3,v_namsp4,v_namsp5,
              spouse_namfirste,spouse_namfirstt,spouse_namfirst3,
              spouse_namfirst4,spouse_namfirst5,spouse_namlaste,spouse_namlastt,spouse_namlast3,spouse_namlast4,
              spouse_namlast5,spouse_numoffid,spouse_dtespbd,spouse_stalife,spouse_dtedthsp,spouse_staincom,
              spouse_desnoffi,spouse_codspocc,spouse_numfasp,spouse_nummosp,spouse_dtemarry,spouse_codsppro,
              spouse_codspcty,spouse_desplreg,spouse_desnote,spouse_filename,v_numrefdoc,global_v_coduser,global_v_coduser);
      update_emp_spouse;
    end if;
  end; -- end save_spouse
  --
  procedure save_children is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_numseq      number;
    v_namche      tchildrn.namche%type;
    v_namcht      tchildrn.namche%type;
    v_namch3      tchildrn.namche%type;
    v_namch4      tchildrn.namche%type;
    v_namch5      tchildrn.namche%type;
    v_numrefdoc   tappldoc.numrefdoc%type;
    v_numappl     varchar2(100 char);
    cursor c_childrn is
      select  codempid,numseq,codtitle,
              namche,namcht,namch3,namch4,namch5,
              namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
              namlaste,namlastt,namlast3,namlast4,namlast5,
              numoffid,dtechbd,codsex,codedlv,stachld,
              stalife,dtedthch,flginc,flgedlv,flgdeduct,
              stabf,filename,numrefdoc,rowid
      from    tchildrn
      where   codempid  = p_codempid_query
      and     numseq    = v_numseq;
  begin
    v_numappl   := get_numappl(p_codempid_query);
    for n in 1..children_tab.count loop
      v_numseq    := children_tab(n).numseq;
      v_numrefdoc := null;
      if p_flg_del_children(n) = 'delete' then
        for i in c_childrn loop
          v_numrefdoc := i.numrefdoc;
        end loop;
        hrpmc2e.update_filedoc( p_codempid_query,
                                null,
                                GET_LABEL_NAME('HRPMC2E3T2',global_v_lang,10),
                                '0003',--- type doc children
                                global_v_coduser,
                                v_numrefdoc);
        delete from tappldoc
        where   numappl   = v_numappl
        and     numrefdoc = ( select  numrefdoc
                              from    tchildrn
                              where   codempid    = p_codempid_query
                              and     numseq      = v_numseq);

        delete from tchildrn
        where   codempid    = p_codempid_query
        and     numseq      = v_numseq;
      else
        v_namche	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',children_tab(n).codtitle,'101')))||
                           ltrim(rtrim(children_tab(n).namfirste))||' '||ltrim(rtrim(children_tab(n).namlaste)),1,60);
        v_namcht	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',children_tab(n).codtitle,'102')))||
                           ltrim(rtrim(children_tab(n).namfirstt))||' '||ltrim(rtrim(children_tab(n).namlastt)),1,60);
        v_namch3	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',children_tab(n).codtitle,'103')))||
                           ltrim(rtrim(children_tab(n).namfirst3))||' '||ltrim(rtrim(children_tab(n).namlast3)),1,60);
        v_namch4	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',children_tab(n).codtitle,'104')))||
                           ltrim(rtrim(children_tab(n).namfirst4))||' '||ltrim(rtrim(children_tab(n).namlast4)),1,60);
        v_namch5	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',children_tab(n).codtitle,'105')))||
                           ltrim(rtrim(children_tab(n).namfirst5))||' '||ltrim(rtrim(children_tab(n).namlast5)),1,60);
        if children_tab(n).numseq > 0 then
          v_exist     := false;
          v_upd       := false;
          for i in c_childrn loop
            v_exist     := true;
            v_numrefdoc := i.numrefdoc;
            upd_log2('tchildrn','32',v_numseq,'codtitle','N','numseq',null,null,'C',i.codtitle,children_tab(n).codtitle,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namche','N','numseq',null,null,'C',i.namche,v_namche,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namcht','N','numseq',null,null,'C',i.namcht,v_namcht,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namch3','N','numseq',null,null,'C',i.namch3,v_namch3,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namch4','N','numseq',null,null,'C',i.namch4,v_namch4,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namch5','N','numseq',null,null,'C',i.namch5,v_namch5,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namfirste','N','numseq',null,null,'C',i.namfirste,children_tab(n).namfirste,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namfirstt','N','numseq',null,null,'C',i.namfirstt,children_tab(n).namfirstt,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namfirst3','N','numseq',null,null,'C',i.namfirst3,children_tab(n).namfirst3,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namfirst4','N','numseq',null,null,'C',i.namfirst4,children_tab(n).namfirst4,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namfirst5','N','numseq',null,null,'C',i.namfirst5,children_tab(n).namfirst5,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namlaste','N','numseq',null,null,'C',i.namlaste,children_tab(n).namlaste,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namlastt','N','numseq',null,null,'C',i.namlastt,children_tab(n).namlastt,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namlast3','N','numseq',null,null,'C',i.namlast3,children_tab(n).namlast3,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namlast4','N','numseq',null,null,'C',i.namlast4,children_tab(n).namlast4,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namlast5','N','numseq',null,null,'C',i.namlast5,children_tab(n).namlast5,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'numoffid','N','numseq',null,null,'C',i.numoffid,children_tab(n).numoffid,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'dtechbd','N','numseq',null,null,'D',to_char(i.dtechbd,'dd/mm/yyyy'),to_char(children_tab(n).dtechbd,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'codsex','N','numseq',null,null,'C',i.codsex,children_tab(n).codsex,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'codedlv','N','numseq',null,null,'C',i.codedlv,children_tab(n).codedlv,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'stachld','N','numseq',null,null,'C',i.stachld,children_tab(n).stachld,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'stalife','N','numseq',null,null,'C',i.stalife,children_tab(n).stalife,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'dtedthch','N','numseq',null,null,'D',to_char(i.dtedthch,'dd/mm/yyyy'),to_char(children_tab(n).dtedthch,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'flginc','N','numseq',null,null,'C',i.flginc,children_tab(n).flginc,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'flgedlv','N','numseq',null,null,'C',i.flgedlv,children_tab(n).flgedlv,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'flgdeduct','N','numseq',null,null,'C',i.flgdeduct,children_tab(n).flgdeduct,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'stabf','N','numseq',null,null,'C',i.stabf,children_tab(n).stabf,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'filename','N','numseq',null,null,'C',i.filename,children_tab(n).filename,'N',v_upd);
            --- update tappldoc ---
            if nvl(i.filename,'#$@') <> nvl(children_tab(n).filename,'#$@') then
              hrpmc2e.update_filedoc( p_codempid_query,
                                      children_tab(n).filename,
                                      GET_LABEL_NAME('HRPMC2E3T2',global_v_lang,10),
                                      '0003',--- type doc children
                                      global_v_coduser,
                                      v_numrefdoc);
            end if;
            -----------------------
            if v_upd then
              update tchildrn
                set	codtitle           = children_tab(n).codtitle,
                    namche             = v_namche,
                    namcht             = v_namcht,
                    namch3             = v_namch3,
                    namch4             = v_namch4,
                    namch5             = v_namch5,
                    namfirste          = children_tab(n).namfirste,
                    namfirstt          = children_tab(n).namfirstt,
                    namfirst3          = children_tab(n).namfirst3,
                    namfirst4          = children_tab(n).namfirst4,
                    namfirst5          = children_tab(n).namfirst5,
                    namlaste           = children_tab(n).namlaste,
                    namlastt           = children_tab(n).namlastt,
                    namlast3           = children_tab(n).namlast3,
                    namlast4           = children_tab(n).namlast4,
                    namlast5           = children_tab(n).namlast5,
                    numoffid           = children_tab(n).numoffid,
                    dtechbd            = children_tab(n).dtechbd,
                    codsex             = children_tab(n).codsex,
                    codedlv            = children_tab(n).codedlv,
                    stachld            = children_tab(n).stachld,
                    stalife            = children_tab(n).stalife,
                    dtedthch           = children_tab(n).dtedthch,
                    flginc             = children_tab(n).flginc,
                    flgedlv            = children_tab(n).flgedlv,
                    flgdeduct          = children_tab(n).flgdeduct,
                    stabf              = children_tab(n).stabf,
                    filename           = children_tab(n).filename,
                    numrefdoc          = v_numrefdoc,
                    coduser            = global_v_coduser
                where rowid = i.rowid;
            end if;
          end loop;

          if not v_exist then
            upd_log2('tchildrn','32',v_numseq,'codtitle','N','numseq',null,null,'C',null,children_tab(n).codtitle,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namche','N','numseq',null,null,'C',null,v_namche,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namcht','N','numseq',null,null,'C',null,v_namcht,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namch3','N','numseq',null,null,'C',null,v_namch3,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namch4','N','numseq',null,null,'C',null,v_namch4,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namch5','N','numseq',null,null,'C',null,v_namch5,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namfirste','N','numseq',null,null,'C',null,children_tab(n).namfirste,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namfirstt','N','numseq',null,null,'C',null,children_tab(n).namfirstt,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namfirst3','N','numseq',null,null,'C',null,children_tab(n).namfirst3,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namfirst4','N','numseq',null,null,'C',null,children_tab(n).namfirst4,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namfirst5','N','numseq',null,null,'C',null,children_tab(n).namfirst5,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namlaste','N','numseq',null,null,'C',null,children_tab(n).namlaste,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namlastt','N','numseq',null,null,'C',null,children_tab(n).namlastt,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namlast3','N','numseq',null,null,'C',null,children_tab(n).namlast3,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namlast4','N','numseq',null,null,'C',null,children_tab(n).namlast4,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'namlast5','N','numseq',null,null,'C',null,children_tab(n).namlast5,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'numoffid','N','numseq',null,null,'C',null,children_tab(n).numoffid,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'dtechbd','N','numseq',null,null,'D',null,to_char(children_tab(n).dtechbd,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'codsex','N','numseq',null,null,'C',null,children_tab(n).codsex,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'codedlv','N','numseq',null,null,'C',null,children_tab(n).codedlv,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'stachld','N','numseq',null,null,'C',null,children_tab(n).stachld,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'stalife','N','numseq',null,null,'C',null,children_tab(n).stalife,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'dtedthch','N','numseq',null,null,'D',null,to_char(children_tab(n).dtedthch,'dd/mm/yyyy'),'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'flginc','N','numseq',null,null,'C',null,children_tab(n).flginc,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'flgedlv','N','numseq',null,null,'C',null,children_tab(n).flgedlv,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'flgdeduct','N','numseq',null,null,'C',null,children_tab(n).flgdeduct,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'stabf','N','numseq',null,null,'C',null,children_tab(n).stabf,'N',v_upd);
            upd_log2('tchildrn','32',v_numseq,'filename','N','numseq',null,null,'C',null,children_tab(n).filename,'N',v_upd);
            if v_upd then
              --- insert tappldoc ---
              hrpmc2e.update_filedoc( p_codempid_query,
                                      children_tab(n).filename,
                                      GET_LABEL_NAME('HRPMC2E3T2',global_v_lang,10),
                                      '0003',--- type doc children
                                      global_v_coduser,
                                      v_numrefdoc);
              -----------------------
              insert into tchildrn
                ( codempid,numseq,codtitle,
                  namche,namcht,namch3,namch4,namch5,
                  namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
                  namlaste,namlastt,namlast3,namlast4,namlast5,
                  numoffid,dtechbd,codsex,codedlv,stachld,
                  stalife,dtedthch,flginc,flgedlv,flgdeduct,
                  stabf,filename,codcreate,coduser,numrefdoc)
              values
                ( p_codempid_query,v_numseq,children_tab(n).codtitle,
                  v_namche,v_namcht,v_namch3,v_namch4,v_namch5,
                  children_tab(n).namfirste,children_tab(n).namfirstt,children_tab(n).namfirst3,children_tab(n).namfirst4,children_tab(n).namfirst5,
                  children_tab(n).namlaste,children_tab(n).namlastt,children_tab(n).namlast3,children_tab(n).namlast4,children_tab(n).namlast5,
                  children_tab(n).numoffid,children_tab(n).dtechbd,children_tab(n).codsex,children_tab(n).codedlv,children_tab(n).stachld,
                  children_tab(n).stalife,children_tab(n).dtedthch,children_tab(n).flginc,children_tab(n).flgedlv,children_tab(n).flgdeduct,
                  children_tab(n).stabf,children_tab(n).filename,global_v_coduser,global_v_coduser,v_numrefdoc);
            end if;
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_children
  --
  procedure save_father_mother is
    v_exist				boolean := false;
    v_upd					boolean := false;

    cursor c_tfamily is
      select  codempid,codempfa,codtitlf,
              namfathe,namfatht,namfath3,namfath4,namfath5,
              namfstfe,namfstft,namfstf3,namfstf4,namfstf5,
              namlstfe,namlstft,namlstf3,namlstf4,namlstf5,
              numofidf,dtebdfa,codfnatn,codfrelg,codfoccu,
              staliff,dtedeathf,filenamf,codempmo,codtitlm,
              nammothe,nammotht,nammoth3,nammoth4,nammoth5,
              namfstme,namfstmt,namfstm3,namfstm4,namfstm5,
              namlstme,namlstmt,namlstm3,namlstm4,namlstm5,
              numofidm,dtebdmo,codmnatn,codmrelg,codmoccu,
              stalifm,dtedeathm,filenamm,codtitlc,
              namconte,namcontt,namcont3,namcont4,namcont5,
              namfstce,namfstct,namfstc3,namfstc4,namfstc5,
              namlstce,namlstct,namlstc3,namlstc4,namlstc5,
              adrcont1,codpost,numtele,numfax,email,desrelat,
              numrefdocf,numrefdocm,rowid
      from    tfamily
      where   codempid = p_codempid_query;

    v_namfathe        tfamily.namfathe%type;
    v_namfatht        tfamily.namfathe%type;
    v_namfath3        tfamily.namfathe%type;
    v_namfath4        tfamily.namfathe%type;
    v_namfath5        tfamily.namfathe%type;

    v_nammothe        tfamily.nammothe%type;
    v_nammotht        tfamily.nammothe%type;
    v_nammoth3        tfamily.nammothe%type;
    v_nammoth4        tfamily.nammothe%type;
    v_nammoth5        tfamily.nammothe%type;

    v_namconte        tfamily.namconte%type;
    v_namcontt        tfamily.namconte%type;
    v_namcont3        tfamily.namconte%type;
    v_namcont4        tfamily.namconte%type;
    v_namcont5        tfamily.namconte%type;

    v_numrefdocf      tappldoc.numrefdoc%type;
    v_numrefdocm      tappldoc.numrefdoc%type;
  begin
    v_namfathe	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlf,'101')))||
                       ltrim(rtrim(famo_namfstfe))||' '||ltrim(rtrim(famo_namlstfe)),1,100);
    v_namfatht	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlf,'102')))||
                       ltrim(rtrim(famo_namfstft))||' '||ltrim(rtrim(famo_namlstft)),1,100);
    v_namfath3	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlf,'103')))||
                       ltrim(rtrim(famo_namfstf3))||' '||ltrim(rtrim(famo_namlstf3)),1,100);
    v_namfath4	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlf,'104')))||
                       ltrim(rtrim(famo_namfstf4))||' '||ltrim(rtrim(famo_namlstf4)),1,100);
    v_namfath5	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlf,'105')))||
                       ltrim(rtrim(famo_namfstf5))||' '||ltrim(rtrim(famo_namlstf5)),1,100);

    v_nammothe	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlm,'101')))||
                       ltrim(rtrim(famo_namfstme))||' '||ltrim(rtrim(famo_namlstme)),1,100);
    v_nammotht	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlm,'102')))||
                       ltrim(rtrim(famo_namfstmt))||' '||ltrim(rtrim(famo_namlstmt)),1,100);
    v_nammoth3	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlm,'103')))||
                       ltrim(rtrim(famo_namfstm3))||' '||ltrim(rtrim(famo_namlstm3)),1,100);
    v_nammoth4	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlm,'104')))||
                       ltrim(rtrim(famo_namfstm4))||' '||ltrim(rtrim(famo_namlstm4)),1,100);
    v_nammoth5	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlm,'105')))||
                       ltrim(rtrim(famo_namfstm5))||' '||ltrim(rtrim(famo_namlstm5)),1,100);

    v_namconte	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlc,'101')))||
                       ltrim(rtrim(famo_namfstce))||' '||ltrim(rtrim(famo_namlstce)),1,100);
    v_namcontt	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlc,'102')))||
                       ltrim(rtrim(famo_namfstct))||' '||ltrim(rtrim(famo_namlstct)),1,100);
    v_namcont3	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlc,'103')))||
                       ltrim(rtrim(famo_namfstc3))||' '||ltrim(rtrim(famo_namlstc3)),1,100);
    v_namcont4	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlc,'104')))||
                       ltrim(rtrim(famo_namfstc4))||' '||ltrim(rtrim(famo_namlstc4)),1,100);
    v_namcont5	:= substr(ltrim(rtrim(get_tlistval_name('CODTITLE',famo_codtitlc,'105')))||
                       ltrim(rtrim(famo_namfstc5))||' '||ltrim(rtrim(famo_namlstc5)),1,100);
    for i in c_tfamily loop
      v_exist       := true;
      --vv father
      v_numrefdocf  := i.numrefdocf;
      v_numrefdocm  := i.numrefdocm;
      upd_log1('tfamily','33','codempfa','C',i.codempfa,famo_codempfa,'N',v_upd);
      upd_log1('tfamily','33','codtitlf','C',i.codtitlf,famo_codtitlf,'N',v_upd);
      upd_log1('tfamily','33','namfathe','C',i.namfathe,v_namfathe,'N',v_upd);
      upd_log1('tfamily','33','namfatht','C',i.namfatht,v_namfatht,'N',v_upd);
      upd_log1('tfamily','33','namfath3','C',i.namfath3,v_namfath3,'N',v_upd);
      upd_log1('tfamily','33','namfath4','C',i.namfath4,v_namfath4,'N',v_upd);
      upd_log1('tfamily','33','namfath5','C',i.namfath5,v_namfath5,'N',v_upd);
      upd_log1('tfamily','33','namfstfe','C',i.namfstfe,famo_namfstfe,'N',v_upd);
      upd_log1('tfamily','33','namfstft','C',i.namfstft,famo_namfstft,'N',v_upd);
      upd_log1('tfamily','33','namfstf3','C',i.namfstf3,famo_namfstf3,'N',v_upd);
      upd_log1('tfamily','33','namfstf4','C',i.namfstf4,famo_namfstf4,'N',v_upd);
      upd_log1('tfamily','33','namfstf5','C',i.namfstf5,famo_namfstf5,'N',v_upd);
      upd_log1('tfamily','33','namlstfe','C',i.namlstfe,famo_namlstfe,'N',v_upd);
      upd_log1('tfamily','33','namlstft','C',i.namlstft,famo_namlstft,'N',v_upd);
      upd_log1('tfamily','33','namlstf3','C',i.namlstf3,famo_namlstf3,'N',v_upd);
      upd_log1('tfamily','33','namlstf4','C',i.namlstf4,famo_namlstf4,'N',v_upd);
      upd_log1('tfamily','33','namlstf5','C',i.namlstf5,famo_namlstf5,'N',v_upd);
      upd_log1('tfamily','33','numofidf','C',i.numofidf,famo_numofidf,'N',v_upd);
      upd_log1('tfamily','33','dtebdfa','D',to_char(i.dtebdfa,'dd/mm/yyyy'),to_char(famo_dtebdfa,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tfamily','33','codfnatn','C',i.codfnatn,famo_codfnatn,'N',v_upd);
      upd_log1('tfamily','33','codfrelg','C',i.codfrelg,famo_codfrelg,'N',v_upd);
      upd_log1('tfamily','33','codfoccu','C',i.codfoccu,famo_codfoccu,'N',v_upd);
      upd_log1('tfamily','33','staliff','C',i.staliff,famo_staliff,'N',v_upd);
      upd_log1('tfamily','33','dtedeathf','D',to_char(i.dtedeathf,'dd/mm/yyyy'),to_char(famo_dtedeathf,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tfamily','33','filenamf','C',i.filenamf,famo_filenamf,'N',v_upd);
      --- update tappldoc ---
      if nvl(i.filenamf,'#$@') <> nvl(famo_filenamf,'#$@') then
        hrpmc2e.update_filedoc( p_codempid_query,
                                famo_filenamf,
                                GET_LABEL_NAME('HRPMC2E3T3',global_v_lang,20),
                                '0004',--- type doc fathers
                                global_v_coduser,
                                v_numrefdocf);
      end if;
      -----------------------
      --vv mother
      upd_log1('tfamily','33','codempmo','C',i.codempmo,famo_codempmo,'N',v_upd);
      upd_log1('tfamily','33','codtitlm','C',i.codtitlm,famo_codtitlm,'N',v_upd);
      upd_log1('tfamily','33','nammothe','C',i.nammothe,v_nammothe,'N',v_upd);
      upd_log1('tfamily','33','nammotht','C',i.nammotht,v_nammotht,'N',v_upd);
      upd_log1('tfamily','33','nammoth3','C',i.nammoth3,v_nammoth3,'N',v_upd);
      upd_log1('tfamily','33','nammoth4','C',i.nammoth4,v_nammoth4,'N',v_upd);
      upd_log1('tfamily','33','nammoth5','C',i.nammoth5,v_nammoth5,'N',v_upd);
      upd_log1('tfamily','33','namfstme','C',i.namfstme,famo_namfstme,'N',v_upd);
      upd_log1('tfamily','33','namfstmt','C',i.namfstmt,famo_namfstmt,'N',v_upd);
      upd_log1('tfamily','33','namfstm3','C',i.namfstm3,famo_namfstm3,'N',v_upd);
      upd_log1('tfamily','33','namfstm4','C',i.namfstm4,famo_namfstm4,'N',v_upd);
      upd_log1('tfamily','33','namfstm5','C',i.namfstm5,famo_namfstm5,'N',v_upd);
      upd_log1('tfamily','33','namlstme','C',i.namlstme,famo_namlstme,'N',v_upd);
      upd_log1('tfamily','33','namlstmt','C',i.namlstmt,famo_namlstmt,'N',v_upd);
      upd_log1('tfamily','33','namlstm3','C',i.namlstm3,famo_namlstm3,'N',v_upd);
      upd_log1('tfamily','33','namlstm4','C',i.namlstm4,famo_namlstm4,'N',v_upd);
      upd_log1('tfamily','33','namlstm5','C',i.namlstm5,famo_namlstm5,'N',v_upd);
      upd_log1('tfamily','33','numofidm','C',i.numofidm,famo_numofidm,'N',v_upd);
      upd_log1('tfamily','33','dtebdmo','D',to_char(i.dtebdmo,'dd/mm/yyyy'),to_char(famo_dtebdmo,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tfamily','33','codmnatn','C',i.codmnatn,famo_codmnatn,'N',v_upd);
      upd_log1('tfamily','33','codmrelg','C',i.codmrelg,famo_codmrelg,'N',v_upd);
      upd_log1('tfamily','33','codmoccu','C',i.codmoccu,famo_codmoccu,'N',v_upd);
      upd_log1('tfamily','33','stalifm','C',i.stalifm,famo_stalifm,'N',v_upd);
      upd_log1('tfamily','33','dtedeathm','D',to_char(i.dtedeathm,'dd/mm/yyyy'),to_char(famo_dtedeathm,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tfamily','33','filenamm','C',i.filenamm,famo_filenamm,'N',v_upd);
      --- update tappldoc ---
      if nvl(i.filenamm,'#$@') <> nvl(famo_filenamm,'#$@') then
        hrpmc2e.update_filedoc( p_codempid_query,
                                famo_filenamm,
                                GET_LABEL_NAME('HRPMC2E3T3',global_v_lang,170),
                                '0005',--- type doc mother
                                global_v_coduser,
                                v_numrefdocm);
      end if;
      -----------------------
      --vv contact
      upd_log1('tfamily','33','codtitlc','C',i.codtitlc,famo_codtitlc,'N',v_upd);
      upd_log1('tfamily','33','namconte','C',i.namconte,v_namconte,'N',v_upd);
      upd_log1('tfamily','33','namcontt','C',i.namcontt,v_namcontt,'N',v_upd);
      upd_log1('tfamily','33','namcont3','C',i.namcont3,v_namcont3,'N',v_upd);
      upd_log1('tfamily','33','namcont4','C',i.namcont4,v_namcont4,'N',v_upd);
      upd_log1('tfamily','33','namcont5','C',i.namcont5,v_namcont5,'N',v_upd);
      upd_log1('tfamily','33','namfstce','C',i.namfstce,famo_namfstce,'N',v_upd);
      upd_log1('tfamily','33','namfstct','C',i.namfstct,famo_namfstct,'N',v_upd);
      upd_log1('tfamily','33','namfstc3','C',i.namfstc3,famo_namfstc3,'N',v_upd);
      upd_log1('tfamily','33','namfstc4','C',i.namfstc4,famo_namfstc4,'N',v_upd);
      upd_log1('tfamily','33','namfstc5','C',i.namfstc5,famo_namfstc5,'N',v_upd);
      upd_log1('tfamily','33','namlstce','C',i.namlstce,famo_namlstce,'N',v_upd);
      upd_log1('tfamily','33','namlstct','C',i.namlstct,famo_namlstct,'N',v_upd);
      upd_log1('tfamily','33','namlstc3','C',i.namlstc3,famo_namlstc3,'N',v_upd);
      upd_log1('tfamily','33','namlstc4','C',i.namlstc4,famo_namlstc4,'N',v_upd);
      upd_log1('tfamily','33','namlstc5','C',i.namlstc5,famo_namlstc5,'N',v_upd);
      upd_log1('tfamily','33','adrcont1','C',i.adrcont1,famo_adrcont1,'N',v_upd);
      upd_log1('tfamily','33','codpost','N',i.codpost,famo_codpost,'N',v_upd);
      upd_log1('tfamily','33','numtele','C',i.numtele,famo_numtele,'N',v_upd);
      upd_log1('tfamily','33','numfax','C',i.numfax,famo_numfax,'N',v_upd);
      upd_log1('tfamily','33','email','C',i.email,famo_email,'N',v_upd);
      upd_log1('tfamily','33','desrelat','C',i.desrelat,famo_desrelat,'N',v_upd);
      if v_upd then
        begin
          update tfamily
            set codempfa = famo_codempfa,
                codtitlf = famo_codtitlf,
                namfathe = v_namfathe,
                namfatht = v_namfatht,
                namfath3 = v_namfath3,
                namfath4 = v_namfath4,
                namfath5 = v_namfath5,
                namfstfe = famo_namfstfe,
                namfstft = famo_namfstft,
                namfstf3 = famo_namfstf3,
                namfstf4 = famo_namfstf4,
                namfstf5 = famo_namfstf5,
                namlstfe = famo_namlstfe,
                namlstft = famo_namlstft,
                namlstf3 = famo_namlstf3,
                namlstf4 = famo_namlstf4,
                namlstf5 = famo_namlstf5,
                numofidf = famo_numofidf,
                dtebdfa = famo_dtebdfa,
                codfnatn = famo_codfnatn,
                codfrelg = famo_codfrelg,
                codfoccu = famo_codfoccu,
                staliff = famo_staliff,
                dtedeathf = famo_dtedeathf,
                filenamf = famo_filenamf,
                numrefdocf = v_numrefdocf,
                codempmo = famo_codempmo,
                codtitlm = famo_codtitlm,
                nammothe = v_nammothe,
                nammotht = v_nammotht,
                nammoth3 = v_nammoth3,
                nammoth4 = v_nammoth4,
                nammoth5 = v_nammoth5,
                namfstme = famo_namfstme,
                namfstmt = famo_namfstmt,
                namfstm3 = famo_namfstm3,
                namfstm4 = famo_namfstm4,
                namfstm5 = famo_namfstm5,
                namlstme = famo_namlstme,
                namlstmt = famo_namlstmt,
                namlstm3 = famo_namlstm3,
                namlstm4 = famo_namlstm4,
                namlstm5 = famo_namlstm5,
                numofidm = famo_numofidm,
                dtebdmo = famo_dtebdmo,
                codmnatn = famo_codmnatn,
                codmrelg = famo_codmrelg,
                codmoccu = famo_codmoccu,
                stalifm = famo_stalifm,
                dtedeathm = famo_dtedeathm,
                filenamm = famo_filenamm,
                numrefdocm = v_numrefdocm,
                codtitlc = famo_codtitlc,
                namconte = v_namconte,
                namcontt = v_namcontt,
                namcont3 = v_namcont3,
                namcont4 = v_namcont4,
                namcont5 = v_namcont5,
                namfstce = famo_namfstce,
                namfstct = famo_namfstct,
                namfstc3 = famo_namfstc3,
                namfstc4 = famo_namfstc4,
                namfstc5 = famo_namfstc5,
                namlstce = famo_namlstce,
                namlstct = famo_namlstct,
                namlstc3 = famo_namlstc3,
                namlstc4 = famo_namlstc4,
                namlstc5 = famo_namlstc5,
                adrcont1 = famo_adrcont1,
                codpost = famo_codpost,
                numtele = famo_numtele,
                numfax = famo_numfax,
                email = famo_email,
                desrelat = famo_desrelat,
                coduser = global_v_coduser
            where rowid = i.rowid;
        end;
      end if;
    end loop;
    if not v_exist and famo_flg = 'add' then
      --vv father
      upd_log1('tfamily','33','codempfa','C',null,famo_codempfa,'N',v_upd);
      upd_log1('tfamily','33','codtitlf','C',null,famo_codtitlf,'N',v_upd);
      upd_log1('tfamily','33','namfathe','C',null,v_namfathe,'N',v_upd);
      upd_log1('tfamily','33','namfatht','C',null,v_namfatht,'N',v_upd);
      upd_log1('tfamily','33','namfath3','C',null,v_namfath3,'N',v_upd);
      upd_log1('tfamily','33','namfath4','C',null,v_namfath4,'N',v_upd);
      upd_log1('tfamily','33','namfath5','C',null,v_namfath5,'N',v_upd);
      upd_log1('tfamily','33','namfstfe','C',null,famo_namfstfe,'N',v_upd);
      upd_log1('tfamily','33','namfstft','C',null,famo_namfstft,'N',v_upd);
      upd_log1('tfamily','33','namfstf3','C',null,famo_namfstf3,'N',v_upd);
      upd_log1('tfamily','33','namfstf4','C',null,famo_namfstf4,'N',v_upd);
      upd_log1('tfamily','33','namfstf5','C',null,famo_namfstf5,'N',v_upd);
      upd_log1('tfamily','33','namlstfe','C',null,famo_namlstfe,'N',v_upd);
      upd_log1('tfamily','33','namlstft','C',null,famo_namlstft,'N',v_upd);
      upd_log1('tfamily','33','namlstf3','C',null,famo_namlstf3,'N',v_upd);
      upd_log1('tfamily','33','namlstf4','C',null,famo_namlstf4,'N',v_upd);
      upd_log1('tfamily','33','namlstf5','C',null,famo_namlstf5,'N',v_upd);
      upd_log1('tfamily','33','numofidf','C',null,famo_numofidf,'N',v_upd);
      upd_log1('tfamily','33','dtebdfa','D',null,to_char(famo_dtebdfa,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tfamily','33','codfnatn','C',null,famo_codfnatn,'N',v_upd);
      upd_log1('tfamily','33','codfrelg','C',null,famo_codfrelg,'N',v_upd);
      upd_log1('tfamily','33','codfoccu','C',null,famo_codfoccu,'N',v_upd);
      upd_log1('tfamily','33','staliff','C',null,famo_staliff,'N',v_upd);
      upd_log1('tfamily','33','dtedeathf','D',null,to_char(famo_dtedeathf,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tfamily','33','filenamf','C',null,famo_filenamf,'N',v_upd);
      --- insert tappldoc ---
      hrpmc2e.update_filedoc( p_codempid_query,
                              famo_filenamf,
                              GET_LABEL_NAME('HRPMC2E3T3',global_v_lang,20),
                              '0004',--- type doc father
                              global_v_coduser,
                              v_numrefdocf);
      -----------------------
      --vv mother
      upd_log1('tfamily','33','codempmo','C',null,famo_codempmo,'N',v_upd);
      upd_log1('tfamily','33','codtitlm','C',null,famo_codtitlm,'N',v_upd);
      upd_log1('tfamily','33','nammothe','C',null,v_nammothe,'N',v_upd);
      upd_log1('tfamily','33','nammotht','C',null,v_nammotht,'N',v_upd);
      upd_log1('tfamily','33','nammoth3','C',null,v_nammoth3,'N',v_upd);
      upd_log1('tfamily','33','nammoth4','C',null,v_nammoth4,'N',v_upd);
      upd_log1('tfamily','33','nammoth5','C',null,v_nammoth5,'N',v_upd);
      upd_log1('tfamily','33','namfstme','C',null,famo_namfstme,'N',v_upd);
      upd_log1('tfamily','33','namfstmt','C',null,famo_namfstmt,'N',v_upd);
      upd_log1('tfamily','33','namfstm3','C',null,famo_namfstm3,'N',v_upd);
      upd_log1('tfamily','33','namfstm4','C',null,famo_namfstm4,'N',v_upd);
      upd_log1('tfamily','33','namfstm5','C',null,famo_namfstm5,'N',v_upd);
      upd_log1('tfamily','33','namlstme','C',null,famo_namlstme,'N',v_upd);
      upd_log1('tfamily','33','namlstmt','C',null,famo_namlstmt,'N',v_upd);
      upd_log1('tfamily','33','namlstm3','C',null,famo_namlstm3,'N',v_upd);
      upd_log1('tfamily','33','namlstm4','C',null,famo_namlstm4,'N',v_upd);
      upd_log1('tfamily','33','namlstm5','C',null,famo_namlstm5,'N',v_upd);
      upd_log1('tfamily','33','numofidm','C',null,famo_numofidm,'N',v_upd);
      upd_log1('tfamily','33','dtebdmo','D',null,to_char(famo_dtebdmo,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tfamily','33','codmnatn','C',null,famo_codmnatn,'N',v_upd);
      upd_log1('tfamily','33','codmrelg','C',null,famo_codmrelg,'N',v_upd);
      upd_log1('tfamily','33','codmoccu','C',null,famo_codmoccu,'N',v_upd);
      upd_log1('tfamily','33','stalifm','C',null,famo_stalifm,'N',v_upd);
      upd_log1('tfamily','33','dtedeathm','D',null,to_char(famo_dtedeathm,'dd/mm/yyyy'),'N',v_upd);
      upd_log1('tfamily','33','filenamm','C',null,famo_filenamm,'N',v_upd);
      --- insert tappldoc ---
      hrpmc2e.update_filedoc( p_codempid_query,
                              famo_filenamm,
                              GET_LABEL_NAME('HRPMC2E3T3',global_v_lang,170),
                              '0005',--- type doc mother
                              global_v_coduser,
                              v_numrefdocm);
      -----------------------
      --vv contact
      upd_log1('tfamily','33','codtitlc','C',null,famo_codtitlc,'N',v_upd);
      upd_log1('tfamily','33','namconte','C',null,v_namconte,'N',v_upd);
      upd_log1('tfamily','33','namcontt','C',null,v_namcontt,'N',v_upd);
      upd_log1('tfamily','33','namcont3','C',null,v_namcont3,'N',v_upd);
      upd_log1('tfamily','33','namcont4','C',null,v_namcont4,'N',v_upd);
      upd_log1('tfamily','33','namcont5','C',null,v_namcont5,'N',v_upd);
      upd_log1('tfamily','33','namfstce','C',null,famo_namfstce,'N',v_upd);
      upd_log1('tfamily','33','namfstct','C',null,famo_namfstct,'N',v_upd);
      upd_log1('tfamily','33','namfstc3','C',null,famo_namfstc3,'N',v_upd);
      upd_log1('tfamily','33','namfstc4','C',null,famo_namfstc4,'N',v_upd);
      upd_log1('tfamily','33','namfstc5','C',null,famo_namfstc5,'N',v_upd);
      upd_log1('tfamily','33','namlstce','C',null,famo_namlstce,'N',v_upd);
      upd_log1('tfamily','33','namlstct','C',null,famo_namlstct,'N',v_upd);
      upd_log1('tfamily','33','namlstc3','C',null,famo_namlstc3,'N',v_upd);
      upd_log1('tfamily','33','namlstc4','C',null,famo_namlstc4,'N',v_upd);
      upd_log1('tfamily','33','namlstc5','C',null,famo_namlstc5,'N',v_upd);
      upd_log1('tfamily','33','adrcont1','C',null,famo_adrcont1,'N',v_upd);
      upd_log1('tfamily','33','codpost','N',null,famo_codpost,'N',v_upd);
      upd_log1('tfamily','33','numtele','C',null,famo_numtele,'N',v_upd);
      upd_log1('tfamily','33','numfax','C',null,famo_numfax,'N',v_upd);
      upd_log1('tfamily','33','email','C',null,famo_email,'N',v_upd);
      upd_log1('tfamily','33','desrelat','C',null,famo_desrelat,'N',v_upd);

      insert into tfamily(codempid,codempfa,codtitlf,namfathe,namfatht,namfath3,namfath4,namfath5,
                          namfstfe,namfstft,namfstf3,namfstf4,namfstf5,
                          namlstfe,namlstft,namlstf3,namlstf4,namlstf5,
                          numofidf,dtebdfa,codfnatn,codfrelg,codfoccu,
                          staliff,dtedeathf,filenamf,numrefdocf,

                          codempmo,codtitlm,nammothe,nammotht,nammoth3,nammoth4,nammoth5,
                          namfstme,namfstmt,namfstm3,namfstm4,namfstm5,
                          namlstme,namlstmt,namlstm3,namlstm4,namlstm5,
                          numofidm,dtebdmo,codmnatn,codmrelg,codmoccu,stalifm,
                          dtedeathm,filenamm,numrefdocm,

                          codtitlc,namconte,namcontt,namcont3,namcont4,namcont5,
                          namfstce,namfstct,namfstc3,namfstc4,namfstc5,
                          namlstce,namlstct,namlstc3,namlstc4,namlstc5,
                          adrcont1,codpost,numtele,numfax,email,desrelat,
                          codcreate,coduser)

                  values (p_codempid_query,famo_codempfa,famo_codtitlf,v_namfathe,v_namfatht,v_namfath3,
                          v_namfath4,v_namfath5,famo_namfstfe,famo_namfstft,famo_namfstf3,
                          famo_namfstf4,famo_namfstf5,famo_namlstfe,famo_namlstft,famo_namlstf3,famo_namlstf4,
                          famo_namlstf5,famo_numofidf,famo_dtebdfa,famo_codfnatn,famo_codfrelg,famo_codfoccu,
                          famo_staliff,famo_dtedeathf,famo_filenamf,v_numrefdocf,

                          famo_codempmo,famo_codtitlm,v_nammothe,v_nammotht,v_nammoth3,v_nammoth4,v_nammoth5,
                          famo_namfstme,famo_namfstmt,famo_namfstm3,famo_namfstm4,famo_namfstm5,
                          famo_namlstme,famo_namlstmt,famo_namlstm3,famo_namlstm4,famo_namlstm5,
                          famo_numofidm,famo_dtebdmo,famo_codmnatn,famo_codmrelg,famo_codmoccu,famo_stalifm,
                          famo_dtedeathm,famo_filenamm,v_numrefdocm,

                          famo_codtitlc,v_namconte,v_namcontt,v_namcont3,v_namcont4,v_namcont5,
                          famo_namfstce,famo_namfstct,famo_namfstc3,famo_namfstc4,famo_namfstc5,
                          famo_namlstce,famo_namlstct,famo_namlstc3,famo_namlstc4,famo_namlstc5,
                          famo_adrcont1,famo_codpost,famo_numtele,famo_numfax,famo_email,famo_desrelat,
                          global_v_coduser,global_v_coduser);
    end if;
  end; -- end save_father_mother
  --
  procedure save_relatives is
    v_exist				boolean := false;
    v_upd					boolean := false;
    v_numseq      number;

    cursor c_trelatives is
      select  codempid,numseq,codemprl,
              namrele,namrelt,namrel3,namrel4,namrel5,
              numtelec,adrcomt,rowid
      from    trelatives
      where   codempid = p_codempid_query
      and     numseq   = v_numseq;
  begin
    for n in 1..relatives_tab.count loop
      relatives_tab(n).codemprl   := check_codempid(relatives_tab(n).codemprl);
      v_numseq    := relatives_tab(n).numseq;
      if p_flg_del_relatives(n) = 'delete' then
        delete from trelatives
        where   codempid    = p_codempid_query
        and     numseq      = v_numseq;
      else
        if relatives_tab(n).numseq > 0 then
          v_exist     := false;
          v_upd       := false;
          for i in c_trelatives loop
            v_exist := true;
            upd_log2('trelatives','34',v_numseq,'codemprl','N','numseq',null,null,'C',i.codemprl,relatives_tab(n).codemprl,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'namrele','N','numseq',null,null,'C',i.namrele,relatives_tab(n).namrele,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'namrelt','N','numseq',null,null,'C',i.namrelt,relatives_tab(n).namrelt,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'namrel3','N','numseq',null,null,'C',i.namrel3,relatives_tab(n).namrel3,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'namrel4','N','numseq',null,null,'C',i.namrel4,relatives_tab(n).namrel4,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'namrel5','N','numseq',null,null,'C',i.namrel5,relatives_tab(n).namrel5,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'numtelec','N','numseq',null,null,'C',i.numtelec,relatives_tab(n).numtelec,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'adrcomt','N','numseq',null,null,'C',i.adrcomt,relatives_tab(n).adrcomt,'N',v_upd);

            if v_upd then
              update trelatives
                set	codemprl    = relatives_tab(n).codemprl,
                    namrele     = relatives_tab(n).namrele,
                    namrelt     = relatives_tab(n).namrelt,
                    namrel3     = relatives_tab(n).namrel3,
                    namrel4     = relatives_tab(n).namrel4,
                    namrel5     = relatives_tab(n).namrel5,
                    numtelec    = relatives_tab(n).numtelec,
                    adrcomt     = relatives_tab(n).adrcomt,
                    coduser     = global_v_coduser
                where rowid     = i.rowid;
            end if;
          end loop;

          if not v_exist then
            upd_log2('trelatives','34',v_numseq,'codemprl','N','numseq',null,null,'C',null,relatives_tab(n).codemprl,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'namrele','N','numseq',null,null,'C',null,relatives_tab(n).namrele,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'namrelt','N','numseq',null,null,'C',null,relatives_tab(n).namrelt,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'namrel3','N','numseq',null,null,'C',null,relatives_tab(n).namrel3,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'namrel4','N','numseq',null,null,'C',null,relatives_tab(n).namrel4,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'namrel5','N','numseq',null,null,'C',null,relatives_tab(n).namrel5,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'numtelec','N','numseq',null,null,'C',null,relatives_tab(n).numtelec,'N',v_upd);
            upd_log2('trelatives','34',v_numseq,'adrcomt','N','numseq',null,null,'C',null,relatives_tab(n).adrcomt,'N',v_upd);
            if v_upd then
              insert into trelatives(codempid,numseq,codemprl,namrele,namrelt,namrel3,
                                     namrel4,namrel5,numtelec,adrcomt,codcreate,coduser)
                             values (p_codempid_query,v_numseq,relatives_tab(n).codemprl,relatives_tab(n).namrele,relatives_tab(n).namrelt,relatives_tab(n).namrel3,
                                     relatives_tab(n).namrel4,relatives_tab(n).namrel5,relatives_tab(n).numtelec,relatives_tab(n).adrcomt,global_v_coduser,global_v_coduser);
            end if;
          end if;
        end if;
      end if;
    end loop;
  end; -- end save_relatives
  --
  function get_last_edit(p_numpage varchar2,
                         p_last_empimg out varchar2,
                         p_last_dteedit out varchar2) return varchar2 is
    v_last_emp      varchar2(100 char);
    v_last_empimg   varchar2(100 char);
    v_last_dteedit  varchar2(100);
    v_additional    number := hcm_appsettings.get_additional_year;
  begin
    begin
      select  distinct get_codempid(coduser),
              to_char(add_months(dteedit,12*v_additional),'dd/mm/yyyy hh24:mi')
      into    v_last_emp, v_last_dteedit
      from    ttemlog1
      where   codempid    = p_codempid_query
      and     numpage     = p_numpage
      and     dteedit     = ( select  max(dteedit)
                              from    ttemlog1
                              where   codempid    = p_codempid_query
                              and     numpage     = p_numpage);
    exception when no_data_found then
      v_last_emp        := '';
      v_last_dteedit    := '';
    end;

    if v_last_emp is not null then
      begin
        select  namimage
        into    v_last_empimg
        from    tempimge
        where   codempid  = v_last_emp;
      exception when no_data_found then
        v_last_empimg   := '';
      end;
    end if;
    p_last_empimg     := v_last_empimg;
    p_last_dteedit    := v_last_dteedit;

    return v_last_emp;
  end; -- end get_last_edit
  --
  procedure get_spouse(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_spouse(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_spouse
  --
  procedure gen_spouse(json_str_output out clob) is
    obj_row           json_object_t;
    v_last_emp        varchar2(100 char);
    v_last_empimg     varchar2(100 char);
    v_last_dteedit    varchar2(100);

    cursor c_tspouse is
      select  codempid,codempidsp,namimgsp,codtitle,
              decode(global_v_lang,'101',namfirste
                                  ,'102',namfirstt
                                  ,'103',namfirst3
                                  ,'104',namfirst4
                                  ,'105',namfirst5) as namfirst,
              namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
              decode(global_v_lang,'101',namlaste
                                  ,'102',namlastt
                                  ,'103',namlast3
                                  ,'104',namlast4
                                  ,'105',namlast5) as namlast,
              namlaste,namlastt,namlast3,namlast4,namlast5,
              numoffid,dtespbd,
              stalife,dtedthsp,staincom,desnoffi,codspocc,
              numfasp,nummosp,dtemarry,codsppro,codspcty,
              desplreg,desnote,filename
      from    tspouse
      where   codempid = p_codempid_query;

    cursor c_default is
      select  fieldname, defaultval
      from    tsetdeflh h, tsetdeflt d
      where   h.codapp            = 'HRPMC2E3'
      and     h.numpage           = 'HRPMC2E31'
      and     d.tablename         = 'TSPOUSE'
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      order by seqno;
  begin
    obj_row    := json_object_t();
    obj_row.put('coderror','200');
    for i in c_default loop -- set default value if not found data
      obj_row.put(lower(i.fieldname),i.defaultval);
    end loop;

    for i in c_tspouse loop
      v_last_emp    := get_last_edit('31',v_last_empimg,v_last_dteedit);

      obj_row.put('coderror','200');
      obj_row.put('codempid',i.codempid);
      obj_row.put('codempidsp',i.codempidsp);
      obj_row.put('namimgsp',i.namimgsp);
      obj_row.put('codtitle',i.codtitle);
      obj_row.put('namfirst',i.namfirst);
      obj_row.put('namfirste',i.namfirste);
      obj_row.put('namfirstt',i.namfirstt);
      obj_row.put('namfirst3',i.namfirst3);
      obj_row.put('namfirst4',i.namfirst4);
      obj_row.put('namfirst5',i.namfirst5);
      obj_row.put('namlast',i.namlast);
      obj_row.put('namlaste',i.namlaste);
      obj_row.put('namlastt',i.namlastt);
      obj_row.put('namlast3',i.namlast3);
      obj_row.put('namlast4',i.namlast4);
      obj_row.put('namlast5',i.namlast5);
      obj_row.put('numoffid',i.numoffid);
      obj_row.put('dtespbd',to_char(i.dtespbd,'dd/mm/yyyy'));
      obj_row.put('stalife',nvl(i.stalife,'Y'));
      obj_row.put('dtedthsp',to_char(i.dtedthsp,'dd/mm/yyyy'));
      obj_row.put('staincom',nvl(i.staincom,'N'));
      obj_row.put('desnoffi',i.desnoffi);
      obj_row.put('codspocc',i.codspocc);
      obj_row.put('numfasp',i.numfasp);
      obj_row.put('nummosp',i.nummosp);
      obj_row.put('dtemarry',to_char(i.dtemarry,'dd/mm/yyyy'));
      obj_row.put('codsppro',i.codsppro);
      obj_row.put('codspcty',i.codspcty);
      obj_row.put('desplreg',i.desplreg);
      obj_row.put('desnote',i.desnote);
      obj_row.put('filename',i.filename);
      obj_row.put('dteupd',v_last_dteedit);
      obj_row.put('coduser',v_last_emp||' - '||get_temploy_name(v_last_emp,global_v_lang));
      obj_row.put('last_empimg',v_last_emp);
    end loop;

    json_str_output := obj_row.to_clob;
  end; -- end gen_spouse
  --
  procedure get_children(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_children(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_children
  --
  procedure gen_children(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number  := 0;
    v_desflgedlv      varchar2(100);
    v_desflgded       varchar2(100);
    cursor c_childrn is
      select  codempid,numseq,codtitle,
              decode(global_v_lang,'101',namche
                                  ,'102',namcht
                                  ,'103',namch3
                                  ,'104',namch4
                                  ,'105',namch5) as namchild,
              decode(global_v_lang,'101',namfirste
                                  ,'102',namfirstt
                                  ,'103',namfirst3
                                  ,'104',namfirst4
                                  ,'105',namfirst5) as namfirst,
              namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
              decode(global_v_lang,'101',namlaste
                                  ,'102',namlastt
                                  ,'103',namlast3
                                  ,'104',namlast4
                                  ,'105',namlast5) as namlast,
              namlaste,namlastt,namlast3,namlast4,namlast5,
              numoffid,dtechbd,codsex,codedlv,stachld,
              stalife,dtedthch,flginc,flgedlv,flgdeduct,
              stabf,filename
      from    tchildrn
      where   codempid = p_codempid_query;
  begin
    obj_row    := json_object_t();
    for i in c_childrn loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('numseq',i.numseq);
      obj_data.put('namchild',i.namchild);
      obj_data.put('codtitle',i.codtitle);
      obj_data.put('desc_codtitle',get_tlistval_name('CODTITLE',i.codtitle,global_v_lang));
      obj_data.put('namfirst',i.namfirst);
      obj_data.put('namfirste',i.namfirste);
      obj_data.put('namfirstt',i.namfirstt);
      obj_data.put('namfirst3',i.namfirst3);
      obj_data.put('namfirst4',i.namfirst4);
      obj_data.put('namfirst5',i.namfirst5);
      obj_data.put('namlast',i.namlast);
      obj_data.put('namlaste',i.namlaste);
      obj_data.put('namlastt',i.namlastt);
      obj_data.put('namlast3',i.namlast3);
      obj_data.put('namlast4',i.namlast4);
      obj_data.put('namlast5',i.namlast5);
      obj_data.put('numoffid',i.numoffid);
      obj_data.put('dtechbd',to_char(i.dtechbd,'dd/mm/yyyy'));
      obj_data.put('codsex',i.codsex);
      obj_data.put('desc_codsex',get_tlistval_name('NAMSEX',i.codsex,global_v_lang));
      obj_data.put('codedlv',i.codedlv);
      obj_data.put('stachld',i.stachld);
      obj_data.put('stalife',i.stalife);
      obj_data.put('dtedthch',to_char(i.dtedthch,'dd/mm/yyyy'));
      obj_data.put('flginc',i.flginc);
      if i.flgedlv = 'Y' then
        v_desflgedlv  := get_label_name('HRPMC2E3P2',global_v_lang,190);
      else
        v_desflgedlv  := get_label_name('HRPMC2E3P2',global_v_lang,200);
      end if;
      if i.flgdeduct = 'Y' then
        v_desflgded  := get_label_name('HRPMC2E3P2',global_v_lang,220);
      else
        v_desflgded  := get_label_name('HRPMC2E3P2',global_v_lang,230);
      end if;
      obj_data.put('flgedlv',i.flgedlv);
      obj_data.put('desc_flgedlv',v_desflgedlv);
      obj_data.put('flgdeduct',i.flgdeduct);
      obj_data.put('desc_flgdeduct',v_desflgded);
      obj_data.put('stabf',i.stabf);
      obj_data.put('filename',i.filename);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end; -- end gen_children
  --
  procedure get_sta_submit_chi(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_tab_children(json_str_input);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_sta_submit_chi
  --
  procedure get_father_mother(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_father_mother(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_father_mother
  --
  procedure gen_father_mother(json_str_output out clob) is
    obj_row           json_object_t;
    v_rcnt            number  := 0;
    v_last_emp        varchar2(100 char);
    v_last_empimg     varchar2(100 char);
    v_last_dteedit    varchar2(100);

    cursor c_tfamily is
      select  codempid,codempfa,codtitlf,
              decode(global_v_lang,'101',namfstfe
                                  ,'102',namfstft
                                  ,'103',namfstf3
                                  ,'104',namfstf4
                                  ,'105',namfstf5) as namfstf,
              namfstfe,namfstft,namfstf3,namfstf4,namfstf5,
              decode(global_v_lang,'101',namlstfe
                                  ,'102',namlstft
                                  ,'103',namlstf3
                                  ,'104',namlstf4
                                  ,'105',namlstf5) as namlstf,
              namlstfe,namlstft,namlstf3,namlstf4,namlstf5,
              numofidf,dtebdfa,codfnatn,codfrelg,codfoccu,
              staliff,dtedeathf,filenamf,codempmo,codtitlm,
              decode(global_v_lang,'101',namfstme
                                  ,'102',namfstmt
                                  ,'103',namfstm3
                                  ,'104',namfstm4
                                  ,'105',namfstm5) as namfstm,
              namfstme,namfstmt,namfstm3,namfstm4,namfstm5,
              decode(global_v_lang,'101',namlstme
                                  ,'102',namlstmt
                                  ,'103',namlstm3
                                  ,'104',namlstm4
                                  ,'105',namlstm5) as namlstm,
              namlstme,namlstmt,namlstm3,namlstm4,namlstm5,
              numofidm,dtebdmo,codmnatn,codmrelg,codmoccu,
              stalifm,dtedeathm,filenamm,codtitlc,
              decode(global_v_lang,'101',namfstce
                                  ,'102',namfstct
                                  ,'103',namfstc3
                                  ,'104',namfstc4
                                  ,'105',namfstc5) as namfstc,
              namfstce,namfstct,namfstc3,namfstc4,namfstc5,
              decode(global_v_lang,'101',namlstce
                                  ,'102',namlstct
                                  ,'103',namlstc3
                                  ,'104',namlstc4
                                  ,'105',namlstc5) as namlstc,
              namlstce,namlstct,namlstc3,namlstc4,namlstc5,
              adrcont1,codpost,numtele,numfax,email,desrelat
      from    tfamily
      where   codempid = p_codempid_query;

    cursor c_default is
      select  fieldname, defaultval
      from    tsetdeflh h, tsetdeflt d
      where   h.codapp            = 'HRPMC2E3'
      and     h.numpage           = 'HRPMC2E33'
      and     d.tablename         = 'TFAMILY'
      and     nvl(h.flgdisp,'Y')  = 'Y'
      and     h.codapp            = d.codapp
      and     h.numpage           = d.numpage
      order by seqno;
  begin
    obj_row    := json_object_t();
    obj_row.put('coderror','200');
    for i in c_default loop -- set default value if not found data
      obj_row.put(lower(i.fieldname),i.defaultval);
    end loop;

    for i in c_tfamily loop
      v_last_emp    := get_last_edit('31',v_last_empimg,v_last_dteedit);

      obj_row.put('coderror','200');
      obj_row.put('codempid',i.codempid);
      obj_row.put('codempfa',i.codempfa);
      obj_row.put('codtitlf',i.codtitlf);
      obj_row.put('namfstf',i.namfstf);
      obj_row.put('namfstfe',i.namfstfe);
      obj_row.put('namfstft',i.namfstft);
      obj_row.put('namfstf3',i.namfstf3);
      obj_row.put('namfstf4',i.namfstf4);
      obj_row.put('namfstf5',i.namfstf5);
      obj_row.put('namlstf',i.namlstf);
      obj_row.put('namlstfe',i.namlstfe);
      obj_row.put('namlstft',i.namlstft);
      obj_row.put('namlstf3',i.namlstf3);
      obj_row.put('namlstf4',i.namlstf4);
      obj_row.put('namlstf5',i.namlstf5);
      obj_row.put('numofidf',i.numofidf);
      obj_row.put('dtebdfa',to_char(i.dtebdfa,'dd/mm/yyyy'));
      obj_row.put('codfnatn',i.codfnatn);
      obj_row.put('codfrelg',i.codfrelg);
      obj_row.put('codfoccu',i.codfoccu);
      obj_row.put('staliff',nvl(i.staliff,'Y'));
      obj_row.put('dtedeathf',to_char(i.dtedeathf,'dd/mm/yyyy'));
      obj_row.put('filenamf',i.filenamf);
      obj_row.put('codempmo',i.codempmo);
      obj_row.put('codtitlm',i.codtitlm);
      obj_row.put('namfstm',i.namfstm);
      obj_row.put('namfstme',i.namfstme);
      obj_row.put('namfstmt',i.namfstmt);
      obj_row.put('namfstm3',i.namfstm3);
      obj_row.put('namfstm4',i.namfstm4);
      obj_row.put('namfstm5',i.namfstm5);
      obj_row.put('namlstm',i.namlstm);
      obj_row.put('namlstme',i.namlstme);
      obj_row.put('namlstmt',i.namlstmt);
      obj_row.put('namlstm3',i.namlstm3);
      obj_row.put('namlstm4',i.namlstm4);
      obj_row.put('namlstm5',i.namlstm5);
      obj_row.put('numofidm',i.numofidm);
      obj_row.put('dtebdmo',to_char(i.dtebdmo,'dd/mm/yyyy'));
      obj_row.put('codmnatn',i.codmnatn);
      obj_row.put('codmrelg',i.codmrelg);
      obj_row.put('codmoccu',i.codmoccu);
      obj_row.put('stalifm',nvl(i.stalifm,'Y'));
      obj_row.put('dtedeathm',to_char(i.dtedeathm,'dd/mm/yyyy'));
      obj_row.put('filenamm',i.filenamm);
      obj_row.put('codtitlc',i.codtitlc);
      obj_row.put('namfstc',i.namfstc);
      obj_row.put('namfstce',i.namfstce);
      obj_row.put('namfstct',i.namfstct);
      obj_row.put('namfstc3',i.namfstc3);
      obj_row.put('namfstc4',i.namfstc4);
      obj_row.put('namfstc5',i.namfstc5);
      obj_row.put('namlstc',i.namlstc);
      obj_row.put('namlstce',i.namlstce);
      obj_row.put('namlstct',i.namlstct);
      obj_row.put('namlstc3',i.namlstc3);
      obj_row.put('namlstc4',i.namlstc4);
      obj_row.put('namlstc5',i.namlstc5);
      obj_row.put('adrcont1',i.adrcont1);
      obj_row.put('codpost',i.codpost);
      obj_row.put('numtele',i.numtele);
      obj_row.put('numfax',i.numfax);
      obj_row.put('email',i.email);
      obj_row.put('desrelat',i.desrelat);
      obj_row.put('dteupd',v_last_dteedit);
      obj_row.put('coduser',v_last_emp||' - '||get_temploy_name(v_last_emp,global_v_lang));
      obj_row.put('last_empimg',v_last_emp);
    end loop;

    json_str_output := obj_row.to_clob;
  end; -- end gen_father_mother
  --
  procedure get_relatives(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_relatives(json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_relatives
  --
  procedure gen_relatives(json_str_output out clob) is
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number  := 0;
    cursor c_trelatives is
      select  codempid,numseq,codemprl,
              decode(global_v_lang,'101',namrele
                                  ,'102',namrelt
                                  ,'103',namrel3
                                  ,'104',namrel4
                                  ,'105',namrel5) as namrel,
              namrele,namrelt,namrel3,namrel4,namrel5,
              numtelec,adrcomt
      from    trelatives
      where   codempid = p_codempid_query;
  begin
    obj_row    := json_object_t();
    for i in c_trelatives loop
      obj_data    := json_object_t();
      v_rcnt      := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('codempid',i.codempid);
      obj_data.put('numseq',i.numseq);
      obj_data.put('codemprl',i.codemprl);
      obj_data.put('namrel',i.namrel);
      obj_data.put('namrele',i.namrele);
      obj_data.put('namrelt',i.namrelt);
      obj_data.put('namrel3',i.namrel3);
      obj_data.put('namrel4',i.namrel4);
      obj_data.put('namrel5',i.namrel5);
      obj_data.put('numtelec',i.numtelec);
      obj_data.put('adrcomt',i.adrcomt);
      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end; -- end gen_relatives
  --
  procedure get_emp_detail(json_str_input in clob, json_str_output out clob) is
    obj_row             json_object_t;
    v_codtitle          temploy1.codtitle%type;
    v_namfirst          temploy1.namfirste%type;
    v_namfirste         temploy1.namfirste%type;
    v_namfirstt         temploy1.namfirstt%type;
    v_namfirst3         temploy1.namfirst3%type;
    v_namfirst4         temploy1.namfirst4%type;
    v_namfirst5         temploy1.namfirst5%type;
    v_namlast           temploy1.namlaste%type;
    v_namlaste          temploy1.namlaste%type;
    v_namlastt          temploy1.namlastt%type;
    v_namlast3          temploy1.namlast3%type;
    v_namlast4          temploy1.namlast4%type;
    v_namlast5          temploy1.namlast5%type;
    v_dteempdb          temploy1.dteempdb%type;
    v_numoffid          temploy2.numoffid%type;
    v_codnatnl          temploy2.codnatnl%type;
    v_codrelgn          temploy2.codrelgn%type;
    v_numtelec          temploy2.numtelec%type;
    v_adrcomt           varchar2(1000);
    v_desc_codcopmy     varchar2(500);
    v_numofidf          tfamily.numofidf%type;
    v_numofidm          tfamily.numofidm%type;
    v_codoccu           varchar2(20);
    v_namimage          tempimge.namimage%type;
  begin
    initial_value(json_str_input);
    begin
      select  codtitle,namfirste,namfirstt,namfirst3,namfirst4,namfirst5,
              decode(global_v_lang,'101',namfirste
                                  ,'102',namfirstt
                                  ,'103',namfirst3
                                  ,'104',namfirst4
                                  ,'105',namfirst5) as namfirst,
              namlaste,namlastt,namlast3,namlast4,namlast5,
              decode(global_v_lang,'101',namlaste
                                  ,'102',namlastt
                                  ,'103',namlast3
                                  ,'104',namlast4
                                  ,'105',namlast5) as namlast,numoffid,
              get_tcompny_name(get_codcompy(emp1.codcomp),global_v_lang) as desc_codcopmy,
              numofidf,numofidm,dteempdb,numtelec,
              decode(global_v_lang,'101',adrcome
                                  ,'102',adrcomt
                                  ,'103',adrcom3
                                  ,'104',adrcom4
                                  ,'105',adrcom5)||' '||cpn.numtele as adrcomt,
              emp2.codnatnl,emp2.codrelgn,'0006' as codoccu,
              img.namimage
      into    v_codtitle,v_namfirste,v_namfirstt,v_namfirst3,v_namfirst4,v_namfirst5,v_namfirst,
              v_namlaste,v_namlastt,v_namlast3,v_namlast4,v_namlast5,v_namlast,v_numoffid,
              v_desc_codcopmy,
              v_numofidf,v_numofidm,v_dteempdb,v_numtelec,
              v_adrcomt,v_codnatnl,v_codrelgn,v_codoccu,
              v_namimage
      from    temploy1 emp1
              left join tcompny cpn on (get_codcompy(emp1.codcomp) = cpn.codcompy)
              left join temploy2 emp2 on (emp1.codempid = emp2.codempid)
              left join tfamily fam on (emp1.codempid = fam.codempid)
              left join tempimge img on (emp1.codempid = img.codempid)
      where   emp1.codempid = p_codempid_query;
    exception when no_data_found then
      null;
    end;
    obj_row   := json_object_t();
    obj_row.put('coderror','200');
    obj_row.put('codtitle',v_codtitle);
    obj_row.put('namfirst',v_namfirst);
    obj_row.put('namfirste',v_namfirste);
    obj_row.put('namfirstt',v_namfirstt);
    obj_row.put('namfirst3',v_namfirst3);
    obj_row.put('namfirst4',v_namfirst4);
    obj_row.put('namfirst5',v_namfirst5);
    obj_row.put('namlast',v_namlast);
    obj_row.put('namlaste',v_namlaste);
    obj_row.put('namlastt',v_namlastt);
    obj_row.put('namlast3',v_namlast3);
    obj_row.put('namlast4',v_namlast4);
    obj_row.put('namlast5',v_namlast5);
    obj_row.put('namemp',get_temploy_name(p_codempid_query,global_v_lang));
    obj_row.put('namempe',get_temploy_name(p_codempid_query,'101'));
    obj_row.put('namempt',get_temploy_name(p_codempid_query,'102'));
    obj_row.put('namemp3',get_temploy_name(p_codempid_query,'103'));
    obj_row.put('namemp4',get_temploy_name(p_codempid_query,'104'));
    obj_row.put('namemp5',get_temploy_name(p_codempid_query,'105'));
    obj_row.put('numoffid',''); -- user4 || 26/12/2022 || #8569 || obj_row.put('numoffid',v_numoffid);
    obj_row.put('desc_codcopmy',v_desc_codcopmy);
    obj_row.put('numofidf',''); -- user4 || 26/12/2022 || #8569 || obj_row.put('numofidf',v_numofidf);
    obj_row.put('numofidm',''); -- user4 || 26/12/2022 || #8569 || obj_row.put('numofidm',v_numofidm);
    obj_row.put('dteempdb',''); -- user4 || 26/12/2022 || #8569 || obj_row.put('dteempdb',to_char(v_dteempdb,'dd/mm/yyyy'));
    obj_row.put('codnatnl',v_codnatnl);
    obj_row.put('codrelgn',v_codrelgn);
    obj_row.put('codoccu',v_codoccu);
    obj_row.put('numtelec',v_numtelec);
    obj_row.put('adrcomt',substr(v_desc_codcopmy||' '||v_adrcomt,1,300));
    obj_row.put('namimage',v_namimage);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- get_emp_detail
  --
  procedure get_popup_change_family(json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    gen_popup_change_family(json_str_input,json_str_output);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- end get_popup_change_edu_work
  --
  procedure gen_popup_change_family(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    obj_data      json_object_t;
    json_obj      json_object_t;
    v_rcnt        number  := 0;
    v_numpage     varchar2(100);
    v_dteempmt    date;

    cursor c1 is
      select  '1' typedit,codempid,dteedit,numpage,fldedit,null as typkey,null as fldkey,
              desold,desnew,flgenc,codtable,coduser,null codedit
      from    ttemlog1
      where   codempid    = p_codempid_query
      and     numpage     = v_numpage

      union

      select  '2' typedit,codempid,dteedit,numpage,fldedit,typkey,fldkey,
              desold,desnew,flgenc,codtable,coduser,
              decode(typkey,'N',to_char(numseq),
                            'C',codseq,
                            'D',to_char(dteseq,'dd/mm/yyyy'),null) as codedit
      from    ttemlog2
      where   codempid    = p_codempid_query
      and     numpage     = v_numpage

      union

      select  '3' typedit,codempid,dteedit,numpage,typdeduct as fldedit,null as typkey,null as fldkey,
              desold,desnew,'Y' flgenc,codtable,coduser,coddeduct codedit
      from    ttemlog3
      where   codempid = p_codempid_query
      and     numpage = v_numpage
      order by dteedit desc,codedit;
  begin
    json_obj        := json_object_t(json_str_input);
    v_numpage       := hcm_util.get_string_t(json_obj,'numpage');
    obj_row         := json_object_t();

    begin
      select  dteempmt into v_dteempmt
      from    temploy1
      where   codempid  = p_codempid_query;
		exception when no_data_found then
			v_dteempmt  := null;
		end;

    for i in c1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror','200');
      obj_data.put('typedit',i.typedit);
      obj_data.put('codempid',i.codempid);
      obj_data.put('dteedit',to_char(i.dteedit,'dd/mm/yyyy hh24:mi:ss'));
      obj_data.put('numpage',i.numpage);
      obj_data.put('fldedit',i.fldedit);
      if i.typedit = '3' then
        obj_data.put('data1',get_tlistval_name('TYPEDEDUCT',i.fldedit,global_v_lang));
        obj_data.put('data2',get_tcodeduct_name(i.codedit,global_v_lang));
      else
        if i.fldedit = 'DTEDUEPR' then
          obj_data.put('data1','ctrl_label4.di_v150');
        else
          obj_data.put('data1',get_tcoldesc_name(i.codtable,i.fldedit,global_v_lang));
        end if;
        obj_data.put('data2',i.codedit);
      end if;
      obj_data.put('typkey',i.typkey);
      obj_data.put('fldkey',i.fldkey);
      if i.flgenc = 'Y' then
        obj_data.put('desold',to_char(stddec(i.desold,p_codempid_query,global_v_chken),'999,999,990.00'));
        obj_data.put('desnew',to_char(stddec(i.desnew,p_codempid_query,global_v_chken),'999,999,990.00'));
      else
        if i.fldedit = 'DTEDUEPR' then
          if i.desold is not null then
            obj_data.put('desold',(add_months(to_date(i.desold,'dd/mm/yyyy'),global_v_zyear*12) - v_dteempmt) +1);
          end if;
          if i.desnew is not null then
            obj_data.put('desnew',(add_months(to_date(i.desnew,'dd/mm/yyyy'),global_v_zyear*12) - v_dteempmt) +1);
          end if;
        else
          obj_data.put('desold',get_desciption (i.codtable,i.fldedit,i.desold));
          obj_data.put('desnew',get_desciption (i.codtable,i.fldedit,i.desnew));
        end if;
      end if;
      obj_data.put('flgenc',i.flgenc);
      obj_data.put('codtable',i.codtable);
      obj_data.put('coduser',i.coduser);
      obj_data.put('codedit',i.codedit);
      obj_data.put('exphighli',get_tsetup_value('SET_HIGHLIGHT'));
      obj_row.put(v_rcnt - 1,obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end; -- gen_popup_change_family
  --
  procedure save_family(json_str_input in clob, json_str_output out clob) is
    param_json                   json_object_t;
    param_json_spouse            json_object_t;
    param_json_children          json_object_t;
    param_json_father_mother     json_object_t;
    param_json_relatives         json_object_t;
  begin
    initial_value(json_str_input);
    param_json                  := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
    param_json_spouse           := hcm_util.get_json_t(param_json,'spouse');
    param_json_children         := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'children'),'rows');
    param_json_father_mother    := hcm_util.get_json_t(param_json,'father_mother');
    param_json_relatives        := hcm_util.get_json_t(hcm_util.get_json_t(param_json,'relatives'),'rows');

    initial_tab_spouse(param_json_spouse);
    initial_tab_children(param_json_children);
    initial_tab_father_mother(param_json_father_mother);
    initial_tab_relatives(param_json_relatives);

    check_tab_spouse;
    check_tab_famo;

    if param_msg_error is null then
      save_spouse;
      save_children;
      save_father_mother;
      save_relatives;

      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    end if;

--    if param_flgwarn = 'WARNE' then
--      param_flgwarn := null;
--    elsif param_flgwarn not like 'WARN%' then
--      param_flgwarn := null;
--    end if;

    json_str_output := get_response_message(null,param_msg_error,global_v_lang,param_flgwarn);
  exception when others then
    rollback;
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end; -- save_family
  --
end;

/

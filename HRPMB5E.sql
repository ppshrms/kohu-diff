--------------------------------------------------------
--  DDL for Package HRPMB5E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMB5E" is
    param_msg_error             varchar2(4000 char);
    v_chken                     varchar2(10 char);
    global_v_coduser            varchar2(100 char);
    global_v_codpswd            varchar2(100 char);
    global_v_lang               varchar2(10 char) := '102';
    global_v_zyear              number := 0;
    global_v_lrunning           varchar2(10 char);
    global_v_zminlvl            number;
    global_v_zwrklvl            number;
    global_v_numlvlsalst        number;
    global_v_numlvlsalen        number;

    p_codcompy                  tincpos.CODCOMPY%type;
    p_codfrm                    tincpos.CODFRM%type;
    p_dteeffec                  date;
    p_dteeffeco                 date;
    p_dteeffecquery             date;
    p_dteeffeChar               varchar2(10 char);
    dateNow                     date;

    v_syncond                   tincpos.SYNCOND%type:= '';
    v_statement                 tincpos.statement%type:= '';
    v_logicdesc                 varchar2(1000 char) := '';
    v_namfrm                    tincpos.NAMFRME%type:= '';
    v_namfrme                   tincpos.NAMFRME%type:= '';
    v_namfrm3                   tincpos.NAMFRM3%type:= '';
    v_namfrm4                   tincpos.NAMFRM4%type:= '';
    v_namfrm5                   tincpos.NAMFRM5%type:= '';
    v_namfrmt                   tincpos.NAMFRMt%type:= '';
    v_mode                      varchar2(20 char)   := 'add';
    v_dteeffec                  varchar2(20 char) := '';
    v_dteeffecD                 date;


    v_amtproba1                   tincpos.AMTPROBA1%type:= '';
    v_amtpacup1                   tincpos.AMTPACUP1%type:= '';
    v_amtproba2                   tincpos.AMTPROBA2%type:= '';
    v_amtpacup2                   tincpos.AMTPACUP2%type:= '';
    v_amtproba3                   tincpos.AMTPROBA3%type:= '';
    v_amtpacup3                   tincpos.AMTPACUP3%type:= '';
    v_amtproba4                   tincpos.AMTPROBA4%type:= '';
    v_amtpacup4                   tincpos.AMTPACUP4%type:= '';
    v_amtproba5                   tincpos.AMTPROBA5%type:= '';
    v_amtpacup5                   tincpos.AMTPACUP5%type:= '';
    v_amtproba6                   tincpos.AMTPROBA6%type:= '';
    v_amtpacup6                   tincpos.AMTPACUP6%type:= '';
    v_amtproba7                   tincpos.AMTPROBA7%type:= '';
    v_amtpacup7                   tincpos.AMTPACUP7%type:= '';
    v_amtproba8                   tincpos.AMTPROBA8%type:= '';
    v_amtpacup8                   tincpos.AMTPACUP8%type:= '';
    v_amtproba9                   tincpos.AMTPROBA9%type:= '';
    v_amtpacup9                   tincpos.AMTPACUP9%type:= '';
    v_amtproba10                  tincpos.AMTPROBA10%type:= '';
    v_amtpacup10                  tincpos.AMTPACUP10%type:= '';  

    isEdit                    boolean := true;
    isAdd                     boolean := false;
    v_flgDisabled             boolean;  

    procedure getIndex (json_str_input in clob, json_str_output out clob);
    procedure genIndex (json_str_output out clob);

    procedure getDetail (json_str_input in clob, json_str_output out clob);
    procedure genDetail (json_str_output out clob);

    procedure save_detail (json_str_input in clob, json_str_output out clob);
    procedure save_detail_main;

    procedure save_index (json_str_input in clob, json_str_output out clob);
    procedure save_index_data (json_str_input in clob, json_str_output out clob);

    procedure gen_flg_status;

end HRPMB5E ;

/

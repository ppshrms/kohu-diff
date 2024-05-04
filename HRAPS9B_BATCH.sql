--------------------------------------------------------
--  DDL for Package HRAPS9B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAPS9B_BATCH" as

    v_chken                 varchar2(4 char):= check_emp(get_emp) ;
    v_lang                  varchar2(3 char);
    v_coduser               varchar2(20 char);
--    v_numproc               number;
    v_process               varchar2(10 char) ;
    v_zyear                 number:= 0;
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    v_numlvlsalst           number;
    v_numlvlsalen           number;
    b_index_sumrec          number;
    b_index_sumerr          number;
    ptcontpm_codcurr        varchar2(40 char) ;
    b_var_codcompy          varchar2(40 char) ;
    ---index
    b_index_dteyreap        number;
    b_index_numtime         number;
    b_index_codcomp         temploy1.codcomp%type;
    b_index_codbon          varchar2(4 char) ;
    b_index_codreq          temploy1.codempid%type;

    para_numproc            number;
    para_codapp             varchar2(10 char);
    para_coduser            varchar2(100 char);
    param_msg_error         varchar2(4000 char);

    procedure start_process (p_codapp  in varchar2,
                             p_coduser in varchar2,
                             p_lang in varchar2,
                             p_numproc in number,
                             p_process in varchar2,
                             p_dteyreap in number,
                             p_numtime in number,
                             p_codcomp in varchar2,
                             p_codbon in varchar2) ;
    procedure gen_group;
    procedure gen_job (p_codapp  in varchar2,
                       p_coduser in varchar2,
                       p_numproc in number,
                       p_process in varchar2,
                       p_dteyreap in number,
                       p_numtime in number,
                       p_codcomp in varchar2,
                       p_codbon in varchar2) ;

    procedure cal_process (p_codapp  in varchar2,
                           p_coduser in varchar2,
                           p_lang in varchar2,
                           p_numproc in number,
                           p_process in varchar2,
                           p_dteyreap in number,
                           p_numtime in number,
                           p_codcomp in varchar2,
                           p_codbon in varchar2) ;

END HRAPS9B_BATCH;

/

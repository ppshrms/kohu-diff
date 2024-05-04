--------------------------------------------------------
--  DDL for Package HRAP3EX_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP3EX_BATCH" as

    v_chken                 varchar2(4):= check_emp(get_emp) ;
    v_lang                  varchar2(3);
    v_coduser               varchar2(20);
    v_numproc               number;
    v_process               varchar2(10) ;
    v_zyear                 number:= 0;
    v_numlvlsalst           number;
    v_numlvlsalen           number;
    b_index_sumrec          number;
    b_index_sumerr          number;

    b_index_codcomp         temploy1.codcomp%type;
    b_index_dteyreap        number;
    b_var_numtime           tstdisd.numtime%type;

    tappemp_codempid        tappemp.codempid%type;

    procedure start_process (p_codapp  in varchar2,
                         p_coduser in varchar2,
                         p_numproc in number,
                         p_process in varchar2 ) ;

    procedure get_parameter (pb_var_codcomp      in varchar2,
                             pb_var_dteyreap     in varchar2,
                             pv_coduser          in varchar2,
                             pv_lang             in varchar2) ;


end HRAP3EX_BATCH;

/

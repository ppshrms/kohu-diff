--------------------------------------------------------
--  DDL for Package HRTR66X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR66X" is

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_zupdsal        varchar2(100 char);
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    json_params             json;
    p_year                  number;
    p_codcomp_query         thistrnn.codcomp%type;
    p_month                 number;

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_index(json_str_output out clob);
    function get_head(p_codempid in varchar2, p_codcomp in varchar2, p_codpos in varchar2) return varchar2;
    procedure get_pos(p_codempid in varchar2, p_codcomp out varchar2, p_codpos out varchar2);
    procedure send_email(json_str_input in clob,json_str_output out clob) ;
    procedure mailing(json_str_output out clob) ;

end HRTR66X;

/

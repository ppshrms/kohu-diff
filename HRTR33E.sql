--------------------------------------------------------
--  DDL for Package HRTR33E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR33E" AS

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';

    param_json          JSON;

    p_codcomp           tbasictp.codcomp%type;
    p_codpos            tbasictp.codpos%type;
    p_codcours          tbasictp.codcours%type;
    p_typemp            varchar2(10 char); --tbasictp.typemp%type;
    p_typemp2           varchar2(10 char); --tbasictp.typemp%type;
    p_qtyposst          tbasictp.qtyposst%type;
    p_codcate           tbasictp.codcate%type;
    p_remark            tbasictp.remark%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_course_from_codcate(json_str_input in clob, json_str_output out clob);

    procedure get_course_from_codcourse(json_str_input in clob, json_str_output out clob);

    procedure get_course_from_competency(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

END HRTR33E;

/

--------------------------------------------------------
--  DDL for Package HRBF21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF21E" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              JSON;

    p_codempid_query        temploy1.codempid%type;
    p_dtereqst              thwccase.dtesmit%type;
    p_dtereqen              thwccase.dtesmit%type;
    p_dteacdst              thwccase.dteacd%type;
    p_dteacden              thwccase.dteacd%type;
    p_codcomp               temploy1.codcomp%type;
--  description parameters
    p_sumday                number;
    p_summth                number;
    p_other_income          number;
    p_location              thwccase.placeacd%type;
    p_codprov               thwccase.codprov%type;
    p_coddistrict           thwccase.coddist%type;
    p_codsubdist            thwccase.codsubdist%type;
    p_dteacd                thwccase.dteacd%type;
    p_timeacd               thwccase.timeacd%type;
    p_dteinform             thwccase.dtenotifi%type;
    p_dtestr                thwccase.dtestr%type;
    p_dteend1               thwccase.dteend%type;
    p_desacd                thwccase.desnote%type;
    p_desresult             thwccase.resultacd%type;
    p_namwitness            thwccase.namwitness%type;
    p_addwitness            thwccase.addrwitness%type;
    p_codclnacd             thwccase.codcln%type;
    p_numpatient            thwccase.idpatient%type;
    p_codclnpriv            thwccase.codclnright%type;
    p_amtadvance            thwccase.amtacomp%type;
    p_codapprove            thwccase.namappr%type;
    p_dtesmit               thwccase.dtesmit%type;
    p_dteadmit              thwccase.dteadmit%type;
    p_numwc                 thwccase.numwc%type;
    p_stawc                 thwccase.stawc%type;


    p_amtday                thwccase.amtday%type;
    p_amtmonth              thwccase.amtmonth%type;
    p_amtother              thwccase.amtother%type;

    p_flag                  varchar2(100 char);
--  compensation parameters
    p_compensation          json;
    p_typpens               tdwccase.typpens%type;
    p_typpensOld            tdwccase.typpens%type;
    p_despens               tdwccase.despens%type;
    p_amtpens               tdwccase.amtpens%type;
    p_dtest                 tdwccase.dtest%type;
    p_dteend2               tdwccase.dtest%type;
    p_flag2                 varchar2(100 char);
--  list form parameters
    p_listform              json;
    p_numseq                thwcattch.numseq%type;
    p_description           thwcattch.description%type;
    p_filename              thwcattch.filename%type;
    p_flag3                 varchar2(100 char);

procedure get_index(json_str_input in clob, json_str_output out clob);

procedure get_detail_tab1(json_str_input in clob, json_str_output out clob);

procedure get_detail_tab1_table(json_str_input in clob, json_str_output out clob);

procedure get_detail_tab2(json_str_input in clob, json_str_output out clob);

procedure save_index(json_str_input in clob, json_str_output out clob);

procedure save_detail(json_str_input in clob, json_str_output out clob);


END HRBF21E;

/

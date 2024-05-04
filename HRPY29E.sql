--------------------------------------------------------
--  DDL for Package HRPY29E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY29E" is
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_chken        varchar2(4000 char);
  v_zupdsal     		    varchar2(4 char);

  p_numperiod           number;
  p_month               number;
  p_year                number;
  p_codcomp             tcenter.codcomp%type;
  p_codempid            temploy1.codempid%type;
  b_index_codempid      temploy1.codempid%type;
  p_typpayroll          temploy1.typpayroll%type;
  p_codpay              tinexinf.codpay%type;
  p_codpay1             tinexinf.codpay%type;
  p_codpay2             tinexinf.codpay%type;
  p_condition           varchar2(4000 char);

  p_tab1                json_object_t;
  p_tab2                json_object_t;

  param_json            json_object_t;
  param_json1           json_object_t;
  param_json2           json_object_t;

  procedure update_tothinc(v_codempid  varchar2,
                           v_numperiod number  ,
                           v_month     number  ,
                           v_year      number  ,
                           v_codpay    varchar2); -- update after commit all
  -- LOG
  procedure add_tlogothinc (v_numseq   number  ,v_codempid varchar2,v_codcomp varchar2,
                            v_desfld   varchar2,v_desold   varchar2,v_desnew  varchar2);
  -- LOG
  procedure add_tlogothpay (v_numseq   number  ,v_codempid varchar2,v_codcomp varchar2,
                            v_desfld   varchar2,v_desold   varchar2,v_desnew  varchar2,
                            v_dtepay   date);

--904  procedure add_tothinc2 (v_codcompw varchar2, v_codempid varchar2,
  procedure add_tothinc2 (v_codcompw varchar2, v_codempid varchar2,v_codcomp2 varchar2,
--904
                          v_qtypayda number  , v_qtypayhr number  ,
                          v_qtypaysc number  , v_amtpay   number  );
--904  procedure edit_tothinc2 (v_codcompw varchar2, v_codempid varchar2,
  procedure edit_tothinc2 (v_codcompw varchar2, v_codempid varchar2,v_codcomp2 varchar2,
--904
                           v_qtypayda number  , v_qtypayhr number  ,
                           v_qtypaysc number  , v_amtpay   number  );
  procedure delete_tothinc2 (v_codcompw varchar2, v_codempid varchar2);

  procedure add_tothpay (v_codcompw varchar2, v_codempid varchar2, v_dtepay    date,
                         v_amtpay   number  , v_flgpyctax varchar2);
  procedure edit_tothpay (v_codcompw varchar2, v_codempid varchar2, v_dtepay    date,
                          v_amtpay   number  , v_flgpyctax varchar2);
  procedure delete_tothpay (v_codcompw varchar2, v_codempid varchar2, v_dtepay date);

  procedure initial_value (json_str_input in clob);
  procedure initial_value_detail (json_str_input in clob);
  procedure initial_value_save (json_str_input in clob);
  procedure initial_save (json_str_input in clob);

  procedure check_index;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_coscenter(json_str_input in clob,json_str_output out clob);
  procedure gen_coscenter(json_str_output out clob);

  procedure get_amtday(json_str_input in clob,json_str_output out clob);
  procedure gen_amtday(json_str_output out clob);

  procedure check_detail1;
  procedure get_detail1(json_str_input in clob,json_str_output out clob);
  procedure gen_detail1(json_str_output out clob);

  procedure check_detail2;
  procedure get_detail2(json_str_input in clob,json_str_output out clob);
  procedure gen_detail2(json_str_output out clob);

  procedure check_save1;
  procedure save1_data(json_str_output out clob);

  procedure check_save2;
  procedure save2_data(json_str_output out clob);

  procedure post_save(json_str_input in clob,json_str_output out clob);

  procedure get_amtpay(json_str_input in clob, json_str_output out clob);

  procedure get_condition_detail_1(json_str_input in clob,json_str_output out clob);
  procedure get_condition_detail_2(json_str_input in clob,json_str_output out clob);

  procedure get_codcompw(json_str_input in clob,json_str_output out clob);

end HRPY29E;

/

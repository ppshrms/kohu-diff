--------------------------------------------------------
--  DDL for Package HRAL99E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL99E" is

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;

  p_codcompy        varchar2(4000 char);
  p_typpayroll      varchar2(4000 char);
  p_grpcodpay       varchar2(4000 char);
  p_dteyrepay       number;
  p_dtemthpay       number;
  p_dtemthpayOld    number;
  p_numperiod       number;
  p_dtestrt         date;
  p_dteend          date;
  p_dtecutst        date;
  p_dtecuten        date;
  p_codpay          varchar2(4 char);
  p_flgcal          varchar2(1 char);

  p_codcompyQuery    TCENTER.CODCOMPY%TYPE;
  p_typpayrollQuery  TCODTYPY.CODCODEC%TYPE;
  p_grpcodpayQuery   TPRIODALGP.GRPCODPAY%TYPE;
  p_dteyrepayQuery   NUMBER;
  p_flgchkpy            boolean;

  isEdit                    boolean := true;
  isAdd                     boolean := false;
  isCopy                    varchar2(1 char) := 'N';
  forceAdd                  varchar2(1 char) := 'N';

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_codpay(json_str_input in clob, json_str_output out clob);
  procedure get_copy_codpay(json_str_input in clob, json_str_output out clob);
  procedure get_group(json_str_input in clob, json_str_output out clob);
  procedure get_codpay_all(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);
  procedure check_paycode(json_str_input in clob, json_str_output out clob); -- ???????????? ?????????????????????o
--  procedure initial_save_data(json_data json);
  procedure check_save_data;
  procedure check_py(p_codcompy varchar2, p_typpayroll varchar2, p_grpcodpay varchar2,p_dteyrepay number, p_dtemthpay number, p_numperiod number);
  procedure add_TPRIODALGP(json_child in json_object_t);    -- insert data to TPRIODALGP then insert codpay to TPRIODAL
  procedure delete_TPRIODALGP(json_child in json_object_t); -- delete data in TPRIODALGP then delete codpay in TPRIODAL
  procedure delete_month; -- ?? month ??????????????????
  procedure edit_month(json_TPRIODALGP_child_list in json_object_t,json_TPRIODAL_child_list in json_object_t);   -- edit ????? ???????????????? ????????????? ???? ?????
  procedure add_TPRIODAL(json_child in json_object_t);      -- insert data to TPRIODAL to all grpcodpay
  procedure delete_TPRIODAL(json_child in json_object_t);   -- delete data in TPRIODAL to all grpcodpay

  procedure get_flg_status (json_str_input in clob, json_str_output out clob);
  procedure gen_flg_status;
  procedure get_copy_list (json_str_input in clob, json_str_output out clob);
  procedure gen_copy_list (json_str_output out clob);
  procedure validate_date_input (v_dtestrt date, v_dteend date, v_dtecutst date, v_dtecuten date);
  procedure delete_case_copy;
end HRAL99E;

/

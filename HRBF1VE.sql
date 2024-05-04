--------------------------------------------------------
--  DDL for Package HRBF1VE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1VE" AS
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  -- save index
  p_codempid_query          trepay.codempid%type;
  p_dteappr                 trepay.dteappr%type;
  p_codappr                 trepay.codappr%type;
  p_amtoutstd               trepay.amtoutstd%type;
  p_qtyrepaym               trepay.qtyrepaym%type;
  p_amtrepaym               trepay.amtrepaym%type;
  p_qtypaid                 trepay.qtypaid%type;
  p_amttotpay               trepay.amttotpay%type;
  p_dtestrpm                trepay.dtestrpm%type;
  p_dtestrpmp               number;
  p_dtestrpmm               number;
  p_dtestrpmy               number;
  p_dtelstpay               trepay.dtelstpay%type;
  p_dtelstpayp              number;
  p_dtelstpaym              number;
  p_dtelstpayy              number;
  p_amtlstpay               trepay.amtlstpay%type;
  p_dteclose                trepay.dteclose%type;
  p_amtclose                trepay.amtclose%type;
  p_remark                  trepay.remark%type;
  p_flgclose                trepay.flgclose%type := 'N';
  p_codcomp                 temploy1.codcomp%type;
  p_typpayroll              temploy1.typpayroll%type;
  -- report
  isInsertReport            boolean := false;
  p_codapp                  varchar2(10 char) := 'HRBF1VE';
  v_additional_year         number := to_number(hcm_appsettings.get_additional_year);
  type arr_1d is table of varchar2(4000 char) index by binary_integer;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure insert_ttemprpt(
    v_dteappr             date,
    v_codappr             varchar2,
    v_amtoutstd           varchar2,
    v_qtyrepaym           varchar2,
    v_amtrepaym           varchar2,
    v_qtypaid             varchar2,
    v_amttotpay           varchar2,
    v_dtestrpm            varchar2,
    v_dtelstpay           varchar2,
    v_amtlstpay           varchar2,
    v_dteclose            date,
    v_amtclose            varchar2,
    v_remark              varchar2,
    v_flgclose            varchar2,
    v_amount              number
  );
END HRBF1VE;

/

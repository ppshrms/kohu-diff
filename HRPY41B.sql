--------------------------------------------------------
--  DDL for Package HRPY41B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY41B" as

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);
  
  global_v_batch_codapp     varchar2(100 char)  := 'HRPY41B';
  global_v_batch_codalw     varchar2(100 char)  := 'HRPY41B';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;

  p_numperiod               number;
  p_dtemthpay               number;
  p_dteyrepay               number;
  p_codcomp                 varchar2(100 char);
  p_typpayroll              varchar2(100 char);
  p_codempid                varchar2(100 char);
  p_flag                    varchar2(1 char);
  p_newflag                 varchar2(1 char);
  p_flgretro                varchar2(1 char);
  p_flglast                 varchar2(1 char);

  b_var_codempid    temploy1.codempid%type;
  b_var_codcompy    tcompny.codcompy%type;
  b_var_typpayroll  temploy1.typpayroll%type;
  b_var_dtebeg      date;
  b_var_dteend      date;
  b_var_ratechge    number;
  b_var_mqtypay     number;
  b_var_balperd     number;
  b_var_perdpay     number;
  b_var_stacal      varchar2(1);
  b_var_staemp      varchar2(1) := 0 ;

  b_var_amtcal      number;
  b_var_dteyreff    number;
  b_var_socfix      number;
  b_var_profix      number;
  b_var_tempinc     number;
  b_var_flglast     varchar2(1);


  b_index_lastperd          number;
  b_index_lstmnt            number;
  b_index_lstyear           number;
  --
  pb_var_codempid      varchar2(100 char);
  pb_var_dteyreff      number ;
  pb_var_codcompy      varchar2(100 char);
  pb_var_typpayroll    varchar2(100 char);
  pb_var_dtebeg        date ;
  pb_var_dteend        date ;
  pb_var_ratechge      number ;
  pb_var_mqtypay       number ;
  pb_var_balperd       number ;
  pb_var_perdpay       number ;
  pb_var_stacal        varchar2(100 char);
  pb_var_amtcal        number ;
  pb_var_socfix        number ;
  pb_var_profix        number ;
  pb_var_tempinc       number ;
  pb_var_flglast       varchar2(100 char);


  ptcontpm_codcurr     varchar2(100 char);
  ptcontrpy_flgfmlsc   varchar2(100 char);
  ptcontrpy_flgfml     varchar2(100 char);
  ptcontrpy_codpaypy1  varchar2(100 char);
  ptcontrpy_codpaypy2  varchar2(100 char);
  ptcontrpy_codpaypy3  varchar2(100 char);
  ptcontrpy_codpaypy4  varchar2(100 char);
  ptcontrpy_codpaypy5  varchar2(100 char);
  ptcontrpy_codpaypy6  varchar2(100 char);
  ptcontrpy_codpaypy7  varchar2(100 char);
  ptcontrpy_codpaypy8  varchar2(100 char);
  ptcontrpy_codtax     varchar2(100 char);
  ptcontrpy_amtminsoc  number;
  ptcontrpy_amtmaxsoc  number;
  ptcontrpy_qtyage     number;
  ptcontpms_codincom1  varchar2(100 char);
  ptcontpms_codincom2  varchar2(100 char);
  ptcontpms_codincom3  varchar2(100 char);
  ptcontpms_codincom4  varchar2(100 char);
  ptcontpms_codincom5  varchar2(100 char);
  ptcontpms_codincom6  varchar2(100 char);
  ptcontpms_codincom7  varchar2(100 char);
  ptcontpms_codincom8  varchar2(100 char);
  ptcontpms_codincom9  varchar2(100 char);
  ptcontpms_codincom10 varchar2(100 char);
  ptcontpms_codretro1  varchar2(100 char);
  ptcontpms_codretro2  varchar2(100 char);
  ptcontpms_codretro3  varchar2(100 char);
  ptcontpms_codretro4  varchar2(100 char);
  ptcontpms_codretro5  varchar2(100 char);
  ptcontpms_codretro6  varchar2(100 char);
  ptcontpms_codretro7  varchar2(100 char);
  ptcontpms_codretro8  varchar2(100 char);
  ptcontpms_codretro9  varchar2(100 char);
  ptcontpms_codretro10 varchar2(100 char);
  ptpfhinf_dteeffec    varchar2(100 char);
  ptssrate_pctsoc      number;

  procedure get_process(json_str_input in clob, json_str_output out clob);
  procedure process_data(json_str_output out clob);

  procedure get_last_date_process(json_str_input in clob, json_str_output out clob);
  procedure get_latest_tax_cal(json_str_input in clob, json_str_output out clob);
  
  function check_index_batchtask(json_str_input clob) return varchar2;
end HRPY41B;

/

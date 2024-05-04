--------------------------------------------------------
--  DDL for Package HRPY90B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY90B" as
    param_msg_error       varchar2(4000 char);
    global_v_coduser      varchar2(100 char);
    global_v_codempid     varchar2(100 char);
    global_v_lang         varchar2(10 char);
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst  number;
    global_v_numlvlsalen  number;
    global_v_chken        varchar2(4000 char);
    global_v_zyear        number := 0;
    v_zupdsal     		    varchar2(4 char);

    global_v_batch_codapp     varchar2(100 char)  := 'HRPY90B';
    global_v_batch_codalw     varchar2(100 char)  := 'HRPY90B';
    global_v_batch_dtestrt    date;
    global_v_batch_flgproc    varchar2(1 char)    := 'N';
    global_v_batch_qtyproc    number              := 0;
    global_v_batch_qtyerror   number              := 0;
    global_v_batch_filename1  varchar2(100 char);
    global_v_batch_pathfile1  varchar2(100 char);
    global_v_batch_filename2  varchar2(100 char);
    global_v_batch_pathfile2  varchar2(100 char);
    global_v_batch_filename3  varchar2(100 char);
    global_v_batch_pathfile3  varchar2(100 char);
    global_v_batch_filename4  varchar2(100 char);
    global_v_batch_pathfile4  varchar2(100 char);

    global_v_pctemppf ttaxcur.pctemppf%type;
    global_v_pctcompf ttaxcur.pctcompf%type;
    global_t_codempid ttaxcur.codempid%type;

    --
    p_numperiod           number;
    p_dtemthpay           number;
    p_dteyrepay           number;
    p_codcompy            tcenter.codcompy%type;
    p_typpayroll          tcodtypy.codcodec%type;
    p_codpfinf            tpfmemb.codpfinf%type;
    p_codplan             tpfmemb.codplan%type;
    p_numcomp             varchar2(4000 char);
    p_numfund             varchar2(4000 char);
    p_dtepay              date;
    p_pvdffmt             tpfphinf.pvdffmt%type;
    p_codpaypy3           tcontrpy.codpaypy3%type;
    p_codpaypy7           tcontrpy.codpaypy7%type;
    --
    p_chk_filebay1        varchar2(1 char);
    p_chk_filebay2        varchar2(1 char);
    --
    p_file_dir            varchar2(4000 char) := 'UTL_FILE_DIR';
    p_file_path           varchar2(4000 char) := get_tsetup_value('PATHEXCEL');
    p_filename            varchar2(4000 char);
    p_filename1           varchar2(4000 char);
    p_filename2           varchar2(4000 char);
    p_filename3           varchar2(4000 char);
    p_sta_group           varchar2(1 char)    := 'N';
    --
    procedure initial_value (json_str_input in clob);
    procedure check_process;
    procedure get_process(json_str_input in clob,json_str_output out clob);
    procedure gen_process(json_str_output out clob);
    -- Export Data Process --
    procedure exp_text_tisco(json_str_output out clob);
    procedure exp_text(json_str_output out clob);

    function check_index_batchtask(json_str_input clob) return varchar2;
  end hrpy90b;

/

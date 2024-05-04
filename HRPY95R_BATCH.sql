--------------------------------------------------------
--  DDL for Package HRPY95R_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY95R_BATCH" is
    para_coduser     temploy1.coduser%type;
    para_chken       varchar2(4);
    para_zyear       number;
    para_lang        varchar2(3);
    param_msg_error       varchar2(4000 char);
    --
    indx_codempid    temploy1.codempid%type;
    indx_codcomp     temploy1.codcomp%type;
    indx_codcompy    tcompny.codcompy%type;
    indx_dteyrepay   number;
    --
    tep1_codempid    temploy1.codempid%type;
    tep1_stamarry    temploy1.stamarry%type;
    tep3_typtax      temploy3.typtax%type;
    tep3_amtincsp    temploy3.amtincsp%type;
    tep3_amtrelas    temploy3.amtrelas%type;
    tep3_amttaxrel   temploy3.amttaxrel%type;

    --
	v_amtexp			number;
	v_maxexp			number;
	v_amtdiff			number;

	TYPE codeduct IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
        dvalue_code	codeduct;
        evalue_code	codeduct;
        ovalue_code	codeduct;
	TYPE char1 IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
        v_text	char1;


  procedure start_process2  (p_codempid  in   varchar2,
                             p_codcomp   in   varchar2,
                             p_dteyrepay in   number,
                             p_chken     in   varchar2,
                             p_zyear     in   number,
                             p_coduser   in   varchar2,
                             p_lang      in   varchar2,
                             p_exit      out  varchar2,
                             p_secur     out  varchar2,
                             global_v_codempid      in   varchar2);

  procedure del_temp (v_codapp varchar2,v_coduser varchar2) ;

  procedure cal_amtnet (p_amtincom  in number,
                        p_amtsalyr  in number,  -- ?????????????????
                        p_amtproyr	in number,  -- ???????????????????? (??? Estimate)
                        p_amtsocyr  in number,  -- ????????????????????? (??? Estimate)
                        p_amtnet	 out number);

  procedure cal_amttax (p_amtnet 	  in number,
                        p_flgtax		in varchar2, --1 ??? ? ???????, 2 ?.??????
                        p_sumtax  	in number,
                        p_taxa  		in number,
                        p_codcompy  in varchar2,
                        p_amttax   out number);

  function gtempded   (v_empid 		in	varchar2,
                       v_codeduct in	varchar2,
                       v_type 		in	varchar2,
                       v_amtcode 	in	number,
                       p_amtsalyr in	number)return number;

  function get_deduct (v_codeduct varchar2) return char;

  function execute_sql (p_stmt in varchar2)  return number;

  procedure ins_temp    (p_codapp			in varchar2,
                         p_numseq			in number,
                         p_codempid		in varchar2,
                         p_namemp			in varchar2,
                         p_numtaxid		in varchar2,
                         p_desmarry		in varchar2,
                         p_destyptax	in varchar2,
                         p_code				in varchar2,
                         p_desc				in varchar2,
                         p_amt				in varchar2);

  procedure tspouse_name    (p_namspous in varchar2,
                             p_codsex   in varchar2,
                             p_titlesp out varchar2,
                             p_firstsp out varchar2,
                             P_LASTSP  OUT varchar2);
  
end hrpy95r_batch;

/

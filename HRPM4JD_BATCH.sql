--------------------------------------------------------
--  DDL for Package HRPM4JD_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM4JD_BATCH" is
--last update: 08/06/2023 16:27 redmine STT#965
--08/03/2021 12:12 redmine #5479
  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;
  global_v_coduser          tusrprof.coduser%type;
  procedure cancel_ttrehire(p_codempid varchar2,p_dteeffec date,p_codtrn varchar2,p_coduser varchar2);
  procedure cancel_ttprobat(p_codempid varchar2,p_dteeffec date,p_codtrn varchar2,p_typproba varchar2,p_coduser varchar2);
--<< user20 Date: 07/09/2021  PM Module- #6140  procedure cancel_ttmistk(p_codempid varchar2,p_dteeffec date,p_codtrn varchar2,p_coduser varchar2);
  procedure cancel_ttmistk(p_codempid varchar2,p_dteeffec date,p_codtrn in out varchar2,p_coduser varchar2);
--<< user20 Date: 07/09/2021  PM Module- #6140
  procedure cancel_ttexempt(p_codempid varchar2,p_dteeffec date,p_codtrn varchar2,p_coduser varchar2);
  procedure cancel_ttmovemt(p_codempid varchar2,p_dteeffec date,p_codtrn varchar2,p_numseq number,p_coduser varchar2);

end HRPM4JD_batch;


/

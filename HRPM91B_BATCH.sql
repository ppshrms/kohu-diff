--------------------------------------------------------
--  DDL for Package HRPM91B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM91B_BATCH" is
-- last update: 16/03/2023 11:12||IPO    
-- last update: 03/02/2023 17:01||sea-HR2201/redmine676    

  v_codcurr    varchar2(10);
  v_chken      varchar2(4)   := check_emp(get_emp) ;
  parameter_numseq    number:= 0;

  v_topic1     varchar2(100) := '60';
  v_topic2     varchar2(100) := '70';
  v_topic3     varchar2(100) := '80';
  v_topic4     varchar2(100) := '90';
  v_topic5     varchar2(100) := '100';
  v_topic6     varchar2(100) := '110';
  v_topic7     varchar2(100) := '120';
  v_topic8     varchar2(100) := '130';
  v_topic9     varchar2(100) := '140'; --user36 10/05/2022

  global_v_batch_codapp     varchar2(100 char)  := 'HRPM91B';

  procedure strart_process  ;


  procedure process_exemption(p_codcomp  in  varchar2,p_codempid in varchar2, p_endate in date,p_coduser in varchar2,
                              o_sum  out number ,o_err out number, p_dtetim in date default sysdate) ;
  procedure process_mistake  (p_codcomp  in  varchar2,p_endate   in date,p_coduser in varchar2,
                             o_sum  out number ,o_err out number, p_dtetim in date default sysdate) ;


  procedure process_movement(p_codcomp   in varchar2,
                              p_endate   in date,
                              p_coduser  in varchar2,
                              p_codempid in varchar2,
                              p_dteeffec in date,
                              p_codtrn   in varchar2,
                              o_sum      out number,
                              o_err      out number,
                              o_user     out number,
                              o_erruser  out number,
                              p_dtetim   in date default sysdate);

  procedure ins_tempinc(p_codempid   in temploy1.codempid%type,
                        p_periodpay  in  tempinc.periodpay%type,
                        p_codpay     in tempinc.codpay%type,
                        p_dtestrt    in tempinc.dtestrt%type,
                        p_dteend     in tempinc.dteend%type,
                        p_amtpay     in tempinc.amtfix%type,
                        p_coduser    in tempinc.coduser%type) ;

  procedure  recal_movement(p_codempid in varchar2,
                            p_dteeffec in date,
                            p_numseq   in number,
                            p_coduser  in varchar2) ;

  procedure process_new_employment (p_codcomp  in  varchar2,p_endate in date ,p_coduser in varchar2,
                                    o_sum      out number,o_err       out number, 
                                    o_user     out number,o_erruser   out number,
                                    p_dtetim in date default sysdate) ;

  procedure process_probation  (p_codcomp  in  varchar2,p_endate   in date,p_coduser in varchar2,
                                o_sum      out number ,o_err out number, p_dtetim in date default sysdate) ;


  procedure replace_codempid(p_codempid in varchar2,p_codnewid in varchar2,p_flgcompdif in varchar2);

  procedure process_reemployment (p_codcomp  in  varchar2,p_endate in date,p_coduser in varchar2,p_flgmove in varchar2,
                                  o_sum      out number,o_err       out number, 
                                  o_user     out number,o_erruser   out number,
                                  p_dtetim in date default sysdate) ;


  procedure ins_errtmp(  p_codempid   varchar2,
                          p_codcomp    varchar2,
                          p_codpos     varchar2,
                          p_code       varchar2,
                          p_table      varchar2,
                          p_topic      varchar2,
                          p_coduser    varchar2);

  procedure gen_temp_tabledup(p_codempid varchar2, p_codempidnew varchar2, p_msg varchar2);

  --<<user36 10/05/2022
  global_v_coduser    tusrprof.coduser%type;

  procedure ins_tusrprof(p_codempid in varchar2);

  procedure ins_tusrcom(p_codempid in varchar2,p_coduser in varchar2,p_type in varchar2);
  procedure ins_tusrproc(p_codempid in varchar2,p_coduser in varchar2,p_type in varchar2);
  procedure ins_tusrlog(p_coduser in varchar2, p_table in varchar2, p_column in varchar2, p_descnew in varchar2, p_descold in varchar2 default null);  
  function get_codcomp_level(p_codcomp in varchar2) return varchar2;
  --
  procedure process_tsecpos(p_codcomp  in  varchar2,p_endate   in date,p_coduser in varchar2,
                            o_sum      out number  ,o_err out number  ,p_dtetim in date default sysdate);
  -->>user36 10/05/2022
  end;

/

--------------------------------------------------------
--  DDL for Package HRAL24B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL24B_BATCH" is
-- last update: 13/02/2021 16:00        --SWD-ST11-1701-AL-02-Rev4.0_04.doc
-- last update: 14/04/2024
  p_coduser   temploy1.coduser%type  := 'AUTO';
  p_chken     varchar2(4)   := check_emp(get_emp);

  procedure start_process;
  procedure cal_process(p_codcomp   in varchar2, 
                        p_coduser   in varchar2, 
                        p_dteeffec  in date,
                        p_dteeffec_en  in date,
                        v_recemp    out number, 
                        v_rectrans  out number,
                        v_recter    out number, 
                        v_recchng   out number);
end;

/

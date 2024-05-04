--------------------------------------------------------
--  DDL for Package STD_BF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_BF" is
--Error ST11/STT-SS-2201/redmine9079 06/02/2023 17:18
  procedure get_medlimit(p_codempid   varchar2,
                                         p_dtereq     date,
                                         p_dtestart   date,
                                         p_numvcher   varchar2,
                                         p_typamt     varchar2,
                                         p_typrel     varchar2,
                                         p_amtwidrwy  out number,
                                         p_qtywidrwy  out number,
                                         p_amtwidrwt  out number,
                                         p_amtacc     out number,
                                         p_amtacc_typ out number,
                                         p_qtyacc        out number,
                                         p_qtyacc_typ out number,
                                         p_amtbal         out number
                                         );

  procedure get_condtypamt(p_codempid   varchar2,
                                                 p_dtereq     date,
                                                 p_dtestart   date,
                                                 p_numvcher   varchar2,
                                                 p_typamt     varchar2,
                                                 p_typrel     varchar2,
                                                 p_amtwidrwy  out number,--
                                                 p_qtywidrwy  out number,
                                                 p_amtwidrwt  out number,
                                                 p_typamt_a   out   varchar2,
                                                 p_typrel_a     out varchar2,
                                                 p_amtwidrwy_a  out number,--
                                                 p_qtywidrwy_a  out number,
                                                 p_amtwidrwt_a  out number
                                                 );

  procedure get_benefit(p_codempid  in varchar2, 
                        p_codobf    in varchar2, 
                        p_codrel    in varchar2,
                        p_dtereq    in date, 
                        p_numseq    in number,
                        p_numvcher  in varchar2,
                        p_amtreq    in number,
                        p_chkemp    in varchar2,--Check emp cond. 'Y'-Yes, 'N'-No                        
                        p_codunit   out varchar2,
                        p_amtvalue  out number, 
                        p_typepay   out varchar2,
                        p_typebf    out varchar2,
                        p_flglimit  out varchar2,
                        p_qtytacc   out number,--Time acc.
                        p_amtacc    out number,--Amount acc.
                        p_qtywidrw  out number,--Quantity Budget
                        p_amtwidrw  out number,--Amount Budget
                        p_qtytalw   out number,--Time Budget
                        p_error     out varchar2);
end;

/

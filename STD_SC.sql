--------------------------------------------------------
--  DDL for Package STD_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_SC" is--TYPLICENSMS
  procedure get_license_Info(p_type_license out varchar2, p_license out number, p_license_Emp out number);
  function chk_license_by_menu(p_codproc varchar2) return varchar2;--HRSC15E
  function chk_license_by_user(p_codproc varchar2, p_coduser varchar2, p_flgact varchar2) return varchar2; --HRSC01E
  function chk_license_by_module(p_codproc varchar2) return varchar2;--HRSC03E, HRPM91B
  function chk_expire return boolean;
end;

/

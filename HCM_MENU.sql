--------------------------------------------------------
--  DDL for Package HCM_MENU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_MENU" is
-- last update: 06/11/2017 10:44

  function get_menu(p_coduser varchar2) return clob;
end;

/

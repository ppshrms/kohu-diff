--------------------------------------------------------
--  DDL for Package SYNC_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "SYNC_CONTROL" is
  procedure update_change (p_custname in varchar, p_type in varchar2, p_name in varchar2);
  procedure initial_customer (p_custname in varchar, p_type in varchar2 default null, p_name in varchar2 default null);
end;

/

--------------------------------------------------------
--  DDL for Package STD_DELTEMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_DELTEMP" is
  p_time      number := 60 / 1440; -- unit minit
	p_path      varchar2(50) := 'UTL_FILE_DIR';--UTL_FILE_CMD
	----------------------------------------------------------
	procedure del_main;
	procedure gen_filedel(p_filetype in varchar2);
  procedure del_file(p_filename in varchar2);
  procedure upd_ttempfile(p_filename in varchar2,p_flgtype in varchar2);	--'A' = Insert,update ,'D'  = delete


/*STD : std_exp
	BF  : hrbf5ix
	ESS : hres38x
	PM  : hrpm51x,hrpm52x,hrpm55r,hrpm56x
	PY  : hrpy35b,hrpy70b,hrpy90b,hrpy91b,hrpy92r,hrpy93r
	RC  : hrrc35x,hrrc36x,hrrc49x */
end;

/

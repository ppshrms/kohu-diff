--------------------------------------------------------
--  DDL for Package Body STD_DELTEMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_DELTEMP" is

procedure del_main is
begin
	gen_filedel(null);	-- null = all file
	/*gen_filedel('txt');
	gen_filedel('log');
	gen_filedel('doc');
	gen_filedel('xls');
	gen_filedel('html');*/
end;
---------------------------------------------------------------------------------------------------------------

procedure gen_filedel(p_filetype in varchar2) is
	v_sysdate  date;
	cursor c_ttempfile is
		select filename
		  from ttempfile
		 where filetype  = nvl(p_filetype,filetype)
		   and dtetime   < v_sysdate;
begin
	v_sysdate := sysdate - p_time;
	---------------------------------------------------
	for r1 in c_ttempfile loop
			del_file(r1.filename);
			upd_ttempfile(r1.filename,'D');
	end loop;
end;
---------------------------------------------------------------------------------------------------------------

procedure del_file(p_filename in varchar2) is
  in_file     utl_file.file_type;
begin
	in_file := utl_file.fopen(p_path,p_filename, 'R');
	if utl_file.is_open(in_file) then
			utl_file.fclose(in_file);
			utl_file.fremove(p_path,p_filename);
	end if;
	exception	when others then
		utl_file.fclose(in_file);
end;
---------------------------------------------------------------------------------------------------------------

procedure upd_ttempfile(p_filename in varchar2, p_flgtype in varchar2) is		--'A' = Insert , update ,'D'  = delete
	v_filetype varchar2(10);
begin
	if p_flgtype = 'D' then
			delete ttempfile where filename = p_filename;
	else
			v_filetype := substr(p_filename,instr(p_filename,'.') + 1);
			begin
				insert into ttempfile(filename,filetype,dtetime)
						 values	(p_filename,v_filetype,sysdate);
			exception when dup_val_on_index then
				update ttempfile set dtetime = sysdate
				 where filename = p_filename;
			end;
	end if;
	commit;
end;

end;

/

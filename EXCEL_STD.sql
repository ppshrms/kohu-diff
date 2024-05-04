--------------------------------------------------------
--  DDL for Package EXCEL_STD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "EXCEL_STD" as
--
  type excel_stdArray is table of varchar2(2000);
--
  procedure show(
      p_file          in utl_file.file_type,
      p_query         in varchar2,
      p_head          in varchar2,
      p_parm_names    in excel_stdArray default excel_stdArray(),
      p_parm_values   in excel_stdArray default excel_stdArray(),
      P_SUM_COLUMN    in EXCEL_STDARRAY default EXCEL_STDARRAY(),
      p_max_rows      in number     default 500000,
      p_show_null_as  in varchar2   default null,
      p_show_grid     in varchar2   default 'YES',
      p_show_col_headers in varchar2 default 'YES',
      p_font_name     in varchar2   default 'Arial Unicode MS',
      p_widths        in excel_stdArray default excel_stdArray(),
      p_titles        in excel_stdArray default excel_stdArray(),
      p_strip_html    in varchar2   default 'YES' );
/*--
  procedure show(
      p_file          in utl_file.file_type,
      p_cursor        in integer,
      p_sum_column    in excel_stdArray  default excel_stdArray(),
      p_max_rows      in number     default 10000,
      p_show_null_as  in varchar2   default null,
      p_show_grid     in varchar2   default 'YES',
      p_show_col_headers in varchar2 default 'YES',
      p_font_name     in varchar2   default 'Arial Unicode MS',
      p_widths        in excel_stdArray default excel_stdArray(),
      p_titles        in excel_stdArray default excel_stdArray(),
      p_strip_html    in varchar2   default 'YES' );
--*/
end EXCEL_STD;

/

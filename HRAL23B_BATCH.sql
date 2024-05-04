--------------------------------------------------------
--  DDL for Package HRAL23B_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL23B_BATCH" is
  v_recs  number;

  procedure start_process   ( p_codapp   varchar2,
                              p_coduser  varchar2,
                              p_numproc  number ,
                              p_dtestr   in	date,
                              p_dteend   in	date ) ;

  procedure create_tattence ( p_codapp     varchar2,
                              p_coduser    varchar2 ,
                              p_data       varchar,
                              p_dtestr  	 in	date,
                              p_dteend  	 in	date,
                              p_codempid	 in	temploy1.codempid%type,
                              p_codcomp 	 in	temploy1.codcomp%type,
                              p_codcalen	 in	temploy1.codcalen%type,
                              p_codempmt	 in	temploy1.codempmt%type,
                              p_typpayroll in	temploy1.typpayroll%type,
                              p_flgatten	 in	temploy1.flgatten%type,
                              p_dteempmt	 in	temploy1.dteempmt%type,
                              p_dteeffex	 in	temploy1.dteeffex%type) ;
end;

/

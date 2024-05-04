--------------------------------------------------------
--  DDL for Package SECUR_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "SECUR_MAIN" is
        zflgsecu      boolean := false;
param_msg_error varchar2(1000 char);
        v_chken       varchar2(4)   := check_emp(get_emp) ;
   --v_chken varchar2(10) := '2310';--check_emp(get_emp);

        function secur1(p_codcomp in varchar2,p_numlvl in number,p_coduser in varchar2,
                        p_zminlvl in number,p_zwrklvl number,p_zupdsal out varchar2,p_numlvlsalst in number default null,p_numlvlsalen in number default null) return boolean;
        function secur2(p_codempid in varchar2,p_coduser in varchar2,
                        p_zminlvl in number,p_zwrklvl number,p_zupdsal out varchar2,p_numlvlsalst in number default null,p_numlvlsalen in number default null) return boolean;
        function secur3(p_codcomp in varchar2,p_codempid in varchar2,p_coduser in varchar2,
                        p_zminlvl in number,p_zwrklvl number,p_zupdsal out varchar2,p_numlvlsalst in number default null,p_numlvlsalen in number default null) return boolean ;
       function secur7(p_codcomp in varchar2,p_coduser in varchar2) return boolean ;

       function secur(p_check in varchar,p_codcomp in varchar2,p_numlvl in number,p_coduser in varchar2,
                      p_zminlvl in number,p_zwrklvl number,p_numlvlsalst in number default null,p_numlvlsalen in number default null)  return varchar ;
    end;

  /*******************/

  /*
  create or replace PACKAGE SECUR_MAIN wrapped
a000000
369
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
67a 14c
mVkYo17fKGpVnnVjTU7UCb1RoAkwg82JrxjWfC9AEjM+i01QDJgCApccJVJ3cGW99N6vDBm1
Yt+jisIGM4qstWxYT/qlbJHUnoqihI+91m2jWjkpgqYEJz1fG1lFiIxafHGdDm+XXliv4kyY
+da58wVKMEpGaitTxz8+CYmrq7oV0fFhQoRzU298Db+kBBLezq393L7wEcUhg+ar08eNjPB2
oEUKs1mY/b6GiQR6vg/0MZ5Y8NanNHoAenF4IyRgS40fnll9D4GeuHdbxk4RozUiJPfr8JEN
cBk5j8ZPIEWkig2dpTpKEr1TCchTxSiag1rVDA==
*/

/

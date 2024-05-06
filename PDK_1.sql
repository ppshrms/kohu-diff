--------------------------------------------------------
--  DDL for Package Body PDK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "PDK" IS


PROCEDURE header(p_desc VARCHAR2,p_coduser VARCHAR2,p_lang VARCHAR2,p_type VARCHAR2)  IS

    v_codempid   temploy1.codempid%type;
    v_name       VARCHAR2(100 char);
    v_pathdad    VARCHAR2(200 char) := PDK.check_pathdad;
    v_title      VARCHAR2(200 char) := ':. Employee Self Service .:';
    v_codproc    VARCHAR2(100 char);
    v_pathportal VARCHAR2(500 char);
BEGIN

    v_codempid := check_codempid(p_coduser);
    v_name     := get_temploy_name(v_codempid,p_lang);
   /* BEGIN
        SELECT codproc INTO v_codproc
        FROM   tusrprof

        WHERE coduser = p_coduser;
    EXCEPTION WHEN no_data_found THEN
       error_page('2010',p_lang);
       RETURN;
    END;*/
    BEGIN
        SELECT substr(value,1,instr(value,'/',-1))||'main.login'
        INTO  v_pathportal
        FROM  tsetup
        where codvalue = 'PATHPORTAL';
    EXCEPTION WHEN no_data_found THEN
       error_page('2010',p_lang);
       RETURN;

    END;
    htp.print('<html>');
    htp.print('<head>');
    htp.print('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" >');
--    htp.print('<meta http-equiv="Content-Type" content="text/html; charset=windows-874" >');
    htp.print('<title>'||v_title||'</title>');
    htp.print('<link rel="stylesheet" href="'||v_pathdad||'StyleSh.css" type="text/css">');

    htp.print('<script language="JavaScript1.2">');
    htp.print('var win_chk = 0;');
    htp.print('function max_win() {');
    htp.print('var  win800 = 780;');
    htp.print('var  win1024 = 1004;');

    htp.print('if (screen.Width == 800 )');
    htp.print('{');
    htp.print(' if (document.body.clientWidth < win800)');
    htp.print(' {');
    htp.print(' top.window.moveTo(0,0);');
    htp.print('    top.window.resizeTo(screen.availWidth,screen.availHeight);');
    htp.print(' }');
    htp.print('}');
    htp.print('else');
    htp.print('{');
    htp.print(' if (document.body.clientWidth < win1024)');
    htp.print(' {');
    htp.print(' top.window.moveTo(0,0);');

    htp.print('    top.window.resizeTo(screen.availWidth,screen.availHeight);');
    htp.print(' }');
    htp.print('}');
    htp.print('}');

    htp.print('function submit_form(action) {');
    htp.print(' document.menu.txt_all.disabled      = 1;');
    htp.print(' document.menu.p_app.disabled        = 1;');
    htp.print(' document.menu.p_code.disabled       = 1;');
    htp.print(' document.menu.txt_label.disabled    = 1;');
    htp.print(' document.menu.flg.disabled          = 1;');
    htp.print(' if  (action == "hres3cu") {');
    htp.print(' document.menu.p_staappr.value = ''X'';');

    htp.print('}');
    htp.print('else');
    htp.print('{');
    htp.print(' document.menu.p_staappr.value = ''P'';');
    htp.print('}');
    htp.print(' document.menu.action = action+''.main'';');
    htp.print(' document.menu.method = ''post'';');
    htp.print(' document.menu.submit();');
    htp.print('}');


    htp.print('function en_lang(){');
    htp.print(' var url1 = (location.href);');

    htp.print(' document.menu.p_lang.value = ''101'';');
    htp.print(' document.menu.txt_all.disabled = 1;');
    htp.print(' document.menu.p_app.disabled = 1;');
    htp.print(' document.menu.p_code.disabled = 1;');
    htp.print(' document.menu.txt_label.disabled = 1;');
    htp.print(' document.menu.flg.disabled = 1;');
    htp.print(' document.menu.txt_all.disabled      = 1;');
    htp.print(' document.menu.p_app.disabled        = 1;');
    htp.print(' document.menu.p_code.disabled       = 1;');
    htp.print(' document.menu.txt_label.disabled    = 1;');
    htp.print(' document.menu.flg.disabled          = 1;');
    htp.print(' document.menu.p_codcomp.disabled = 0;');
    htp.print(' document.menu.p_dtest.disabled = 0;');

    htp.print(' document.menu.p_dteen.disabled = 0;');
    htp.print(' document.menu.p_staappr.disabled = 0;');
    htp.print(' document.menu.p_codempid.disabled = 0;');



    htp.print(' document.menu.action = url1;');
    htp.print(' document.menu.method = ''post'';');
    htp.print(' document.menu.submit();');
    htp.print('            }  // End en_lang       ');

    htp.print('function th_lang(){');
    htp.print(' var url1 = (location.href);');

    htp.print(' document.menu.p_lang.value = ''102'';');
    htp.print(' document.menu.txt_all.disabled = 1;');
    htp.print(' document.menu.p_app.disabled = 1;');
    htp.print(' document.menu.p_code.disabled = 1;');
    htp.print(' document.menu.txt_label.disabled = 1;');
    htp.print(' document.menu.flg.disabled = 1;');
    htp.print(' document.menu.p_codcomp.disabled = 0;');
    htp.print(' document.menu.p_dtest.disabled = 0;');
    htp.print(' document.menu.p_dteen.disabled = 0;');
    htp.print(' document.menu.p_staappr.disabled = 0;');
    htp.print(' document.menu.p_codempid.disabled = 0;');

    htp.print(' document.menu.action = url1;');

    htp.print(' document.menu.method = ''post'';');
    htp.print(' document.menu.submit();');
    htp.print('            }   // End th_lang      ');


    htp.print('</script>');
    htp.print('<SCRIPT LANGUAGE="JavaScript">');
    htp.print('//===============  Check Form  =============//');
    htp.print('var total = 0;');
    htp.print('function chk_value1(form) {');
    htp.print('var v_cnt = 0;');
    htp.print(' document.menu.p_code.value ='''';');
    htp.print(' if (form == null) {   // Check Checkbox ');

    --htp.print('   alert("'||PDK.error_msg(2010,p_lang)||'"); ');
    htp.print(' alert("'||PDK.error_msg('HR2010',p_lang)||'"); ');
    htp.print('                           }');
    htp.print(' else {');
    htp.print('     if (form.length == null) {  // Check number of Checkbox');
    htp.print('        if (form.checked == true) {');
    htp.print('           document.menu.p_code.value = document.menu.p_code.value + form.value; ');
    htp.print('           total = 1;');
    htp.print('           form.checked = false;  }');
  --  htp.print('             document.menu.p_total.value = total;');
    htp.print('                               }');
    htp.print('     else {');
    htp.print('         for (i = 0; i < form.length; i++) {');

    htp.print('             if (form[i].checked == true) {');
    htp.print('                v_cnt += 1;');
    htp.print('               if (v_cnt == 1) {');
    htp.print('                   document.menu.p_code.value = form[i].value;');
    htp.print('                               }');
    htp.print('               else{');
    htp.print('                   document.menu.p_code.value = document.menu.p_code.value+ "&" +form[i].value;');
    htp.print('                   }');
    htp.print('                total += 1;');
    htp.print('                form[i].checked = false;');
    htp.print('                                           } ');
    htp.print('                                            } ');
  --  htp.print('            document.menu.p_total.value = total;');

    htp.print('              }       ');
    htp.print('if (document.menu.p_code.value == ''''){');
    --htp.print('      alert("'||PDK.error_msg(2030,p_lang)||'"); ');
    htp.print('    alert("'||PDK.error_msg('HR2030',p_lang)||'"); ');
    htp.print('                                       }');
    htp.print('else {');
    htp.print(' document.menu.flg.checked = false;   ');
    htp.print(' document.menu.flg.disabled =1;');
    htp.print(' var param1 = document.menu.p_app.value+"?";');
    htp.print(' var param2 = document.menu.p_code.value;');
    htp.print(' var param3 = "&p_coduser=" + document.menu.p_coduser.value;');
    htp.print(' var param4 = "&p_lang=" + document.menu.p_lang.value;');
    htp.print(' var param5 = "&p_codcomp=" + document.menu.p_codcomp.value;');

    htp.print(' var param6 = "&p_dtest=" + document.menu.p_dtest.value;');
    htp.print(' var param7 = "&p_dteen=" + document.menu.p_dteen.value;');
    htp.print(' var param8 = "&p_staappr=" + document.menu.p_staappr.value;');
    htp.print(' var param9 = "&p_codempid=" + document.menu.p_codempid.value;');
    htp.print(' var param10 = param1+param2+param3+param4+param5+param6+param7+param8+param9;');
    htp.print(' document.menu.flg.style.visibility = ''hidden'';');
    htp.print(' document.menu.txt_all.style.visibility = ''hidden'';');
    htp.print(' document.menu.bu_main.style.visibility = ''hidden'';');
    htp.print(' main.location.href = param10;');
    htp.print('              }');
    htp.print('      }');
    htp.print('}'); -- Check Value 1



    htp.print('function chk_value2(form,p_type) {');
    htp.print('var total = 0;');
    htp.print('document.menu.p_code.value ='''';');
    htp.print('if (form == null) {   // Check Checkbox  ');
    --htp.print('   alert("'||PDK.error_msg(2010,p_lang)||'"); ');
    htp.print(' alert("'||PDK.error_msg('HR2010',p_lang)||'"); ');
    htp.print('                           }');
    htp.print('else {');
    htp.print('     if (form.length == null) {  // Check number of Checkbox');
    htp.print('                  if (form.checked == true) {');
    htp.print('                    document.menu.p_code.value = document.menu.p_code.value + form.value;');
    htp.print('                     total = 1;');

    htp.print('                                                                  }');
    htp.print('                                                }');
    htp.print('     else {  ');
    htp.print('                 for (var i = 0; i < form.length; i++) {');
    htp.print('                     if (form[i].checked == true) {');
    htp.print('                     document.menu.p_code.value = document.menu.p_code.value+form[i].value;');
    htp.print('                     total += 1;');
    htp.print('                                                                         }');
    htp.print('                                                                                 }                    ');
    htp.print('                  ');
    htp.print('                  }         ');
    htp.print('     if (total == 0 ){');
    --htp.print('   alert("'||PDK.error_msg(2030,p_lang)||'"); ');

    htp.print(' alert("'||PDK.error_msg('HR2030',p_lang)||'"); ');
    htp.print('                            }');
    htp.print('     else if (total  > 1){');
    --htp.print('   alert("'||PDK.error_msg(2035,p_lang)||'"); ');
    htp.print(' alert("'||PDK.error_msg('HR2035',p_lang)||'"); ');
    htp.print('                                     }');
    htp.print('     else {');
    htp.print(' document.menu.flg.disabled =1;');
    htp.print(' var param1 = document.menu.p_app.value+"?";');
    htp.print(' var param2 = document.menu.p_code.value;');
    htp.print(' var param3 = "&p_coduser=" + document.menu.p_coduser.value;');
    htp.print(' var param4 = "&p_lang=" + document.menu.p_lang.value;');
    htp.print(' var param5 = "&p_codcomp=" + document.menu.p_codcomp.value;');

    htp.print(' var param6 = "&p_dtest=" + document.menu.p_dtest.value;');
    htp.print(' var param7 = "&p_dteen=" + document.menu.p_dteen.value;');
    htp.print(' var param8 = "&p_staappr=" + document.menu.p_staappr.value;');
    htp.print(' var param9 = "&p_codempid=" + document.menu.p_codempid.value;');
    htp.print(' var param10 = param1+param2+param3+param4+param5+param6+param7+param8+param9;');
    htp.print('     if (p_type == ''S'' ){');
    htp.print(' document.menu.bu_edit.style.visibility    = ''hidden'';');
    htp.print('                          }');
    htp.print('     else{');
    htp.print(' document.menu.bu_main.style.visibility    = ''hidden'';');
    htp.print('         }');
    htp.print(' main.location.href = param10;');
    htp.print('               }');

    htp.print('   }  // End Else  First ');
    htp.print('}  // End  chk_value2');


    htp.print('//===============  Check All / Uncheck All ================//');
    -----Up date 14/03/2007 By Pratya -----
    htp.print('function check_all(form) {');
    htp.print(' var  v_chk ;');
    htp.print(' if (form == null) {   // Check Checkbox ');
    --htp.print('   alert("'||PDK.error_msg(2010,p_lang)||'"); ');
    htp.print(' alert("'||PDK.error_msg('HR2010',p_lang)||'"); ');
    htp.print('    document.menu.flg.disabled = true;   ');
    htp.print('    document.menu.flg.checked  = false;  ');

    htp.print('                           }');
    htp.print(' else {');
    htp.print('         if (form.length == null) {  // Check number of Checkbox');
    htp.print('             if (document.menu.flg.checked == true) {');
    htp.print('                 form.checked = true;');
    htp.print('                 return "Uncheck All"; }');
    htp.print('             else {');
    htp.print('                 form.checked = false; ');
    htp.print('                 return "Check All"; }}');
    htp.print('         else {');
    htp.print('             v_chk = 0 ;');
    htp.print('             if (document.menu.flg.checked == true) {');
    htp.print('                 for (i = 0; i < form.length; i++) {');

    htp.print('                 v_chk = v_chk + 1; ');
    htp.print('                 if (v_chk < 36){');
    htp.print('                    form[i].checked = true;}');
    htp.print('                 else{form[i].checked = false;}');
    htp.print('                 }');
    htp.print('                 return "Uncheck All"; }');
    htp.print('             else {');
    htp.print('                 for (i = 0; i < form.length; i++) {');
    htp.print('                 form[i].checked = false; }');
    htp.print('                 return "Check All"; }');
    htp.print('                 }');
    htp.print('             }');
    htp.print('        }');


    /*htp.print('var checkflag = "false";');
    htp.print('function check_all(form) {');
    htp.print(' if (form == null) {   // Check Checkbox ');
    htp.print(' alert("'||PDK.error_msg(2010,p_lang)||'"); ');
    htp.print('    document.menu.flg.disabled = true;   ');
    htp.print('    document.menu.flg.checked  = false;  ');
    htp.print('                           }');
    htp.print(' else {');
    htp.print('         if (form.length == null) {  // Check number of Checkbox');
    htp.print('             if (document.menu.flg.checked == true) {');
    htp.print('                 form.checked = true;');
    htp.print('                 checkflag = "true";');

    htp.print('                 return "Uncheck All"; }');
    htp.print('             else {');
    htp.print('                 form.checked = false; ');
    htp.print('                 checkflag = "false";');
    htp.print('                 return "Check All"; }}');
    htp.print('         else {');
    htp.print('             if (document.menu.flg.checked == true) {');
    htp.print('                 for (i = 0; i < form.length; i++) {');
    htp.print('                 form[i].checked = true;}');
    htp.print('                 checkflag = "true";');
    htp.print('                 return "Uncheck All"; }');
    htp.print('             else {');
    htp.print('                 for (i = 0; i < form.length; i++) {');

    htp.print('                 form[i].checked = false; }');
    htp.print('                 checkflag = "false";');
    htp.print('                 return "Check All"; }');
    htp.print('                 }');
    htp.print('             }');
    htp.print('        }'); */ -- Check_all

    htp.print('function chk_record(){');
    IF p_type = 'M' THEN
    htp.print('if (main.form1.chk == null) { ');
    htp.print('document.menu.flg.disabled =1;');
    htp.print('document.menu.bu_main.disabled =1;');
    htp.print('document.menu.txt_all.disabled =1;');

    htp.print('} else{');
    htp.print('document.menu.flg.disabled =0;');
    htp.print('document.menu.bu_main.disabled =0;');
    htp.print('document.menu.txt_all.disabled =0;');
    htp.print('}');
    ELSIF p_type = 'S' THEN
    htp.print('if (main.form1.chk == null) { ');
    htp.print('document.menu.flg.disabled =1;');
    htp.print('} else{');
    htp.print('document.menu.flg.disabled =0;');
    htp.print('}');
    ELSE
       htp.print('// Nothing //');

    END IF;
    htp.print('                          }');

    htp.print('function call_leave() {');
    htp.print('var  popW = 750;');
    htp.print('var  popH = 500;');
    htp.print('var  scroll = "no";');
    htp.print('var  winleft     = (screen.width - popW) / 2;');
    htp.print('var  winUp       = (screen.height - popH) / 3;');
    htp.print('var  v_dteworkst = '''';');
    htp.print('var  v_dteworken = '''';');
    htp.print('var  v_codcomp   = '''';');
    htp.print('var  v_codshift  = '''';');

    --htp.print('var  d_link1  = ''hres63u.list_req_leave$p_dteworkst=''+v_dteworkst+''!p_dteworken=''+v_dteworken+''!p_codcomp=''+v_codcomp+''!p_codshift=''+v_codshift+''!p_lang='||p_lang||' ''; ');
    htp.print('var  d_link1  = ''hres63u.list_req_leave$p_dteworkst=''+v_dteworkst+''!p_dteworken=''+v_dteworken+''!p_codcomp=''+v_codcomp+''!p_codshift=''+v_codshift+''!p_lang='||p_lang||'+!p_coduser='||p_coduser||' ''; '); --04/06/09 -- Mr.Sam
    --htp.print('var  v_link = ''hres63u.std_dialog?p_link1=''+d_link1+''&p_dteworkst=''+v_dteworkst+''&p_dteworken=''+v_dteworken+''&p_codcomp=''+v_codcomp+''&p_codshift=''+v_codshift+''&p_lang='||p_lang||' ''; ');
    htp.print('var  v_link = ''hres63u.std_dialog?p_link1=''+d_link1+''&p_dteworkst=''+v_dteworkst+''&p_dteworken=''+v_dteworken+''&p_codcomp=''+v_codcomp+''&p_codshift=''+v_codshift+''&p_lang='||p_lang||'&p_coduser2='||p_coduser||' ''; '); --04/06/09 -- Mr.Sam
    htp.print('winProp = ''width=''+popW+'',height=''+popH+'',left=''+winleft+'',top=''+winUp+'',scrollbars=''+scroll+'',resizable=0''');
    htp.print('Win     = window.open(v_link, ''Ctrlwindow'', winProp)');
    htp.print('}');

    htp.print('</script>');


    htp.print('</head>');
    htp.print('<body onLoad="max_win();chk_record()" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">');

    htp.print('   <table cellpadding="0" cellspacing="0" border="0" width="100%" height="50">');

    htp.print(' <tr>');
    htp.print('   <td valign="top" colspan="2" height="56">');
    htp.print('     <table width="100%" border="0" cellspacing="0" cellpadding="0">');
    htp.print('       <tr>');
    htp.print('         <td height="75">');
    htp.print('           <table width="100%" border="0" cellspacing="0" cellpadding="0">');
    htp.print('             <tr>');
    htp.print('               <td width="195" background="'||v_pathdad||'head_l2.gif" height="48" align="center"></td>');
    htp.print('               <td width="465" background="'||v_pathdad||'head_l3.gif" height="48" align="center"></td>');
    htp.print('               <td background="'||v_pathdad||'head_essr.gif">&nbsp;</td>');
    --htp.print('               <td width="316"><img src="'||v_pathdad||'head_essr.gif" width="338" height="48"></td>');

    htp.print('               <td width="316"><img src="'||v_pathdad||'head_essr.gif" width="338" height="48"></td>');
    htp.print('             </tr>');
    htp.print('             <tr>');
    htp.print('               <td width="195" height="27"><img src="'||v_pathdad||'head_ess.gif" width="195" height="27"></td>                                                                                                                                                                                                  ');
    --htp.print('               <td background="'||v_pathdad||'head_title_m.gif" class="Textbody"  valign="bottom" valign="bottom" >&nbsp;&nbsp;<FONT color="#FFFFFF" >'||p_desc||'</FONT> </td>');
    htp.print('               <td background="'||v_pathdad||'head_title_m.gif" class="Textbody"  valign="bottom" valign="bottom" >&nbsp;&nbsp; </td>');
    htp.print('               <td background="'||v_pathdad||'head_u_essr.gif" </td>');
    --htp.print('               <td width="316" vlign="right" background="'||v_pathdad||'head_title_m.gif" >');
    htp.print('               <td width="316" valign="right" background="'||v_pathdad||'head_u_essr.gif" valign="bottom">');
    htp.print('                  <table width="100%" border="0" cellspacing="0" cellpadding="0"  >');
    htp.print('                    <tr>');
    htp.print('                      <td width="150" class="TextBody" align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;  </td>');
    htp.print('                      <td width="50%" align="right" class="TextBody"><FONT color="#FFFFFF">'||v_codempid ||' '||v_name||' &nbsp;&nbsp;&nbsp;</FONT></td>');

    htp.print('                      <td width="2%"><a href="Javascript:en_lang();"><img src="'||v_pathdad||'us.gif" Width="20" Height="18" Border="0"></A></td>');
    htp.print('                      <td width="2%"><a href="Javascript:th_lang();"><img src="'||v_Pathdad||'th.gif" Width="20" Height="18" Border="0"></A></td>');
    htp.print('                    </tr>');
    htp.print('                  </table>');
    htp.print('               </td>');
    htp.print('             </tr>');
    htp.print('           </table>');
    htp.print('         </td>');
    htp.print('       </tr>');
    /*
    htp.print('       <tr>');
    htp.print('         <td align="left" bgcolor="#003366" height="5"></td>');
    htp.print('       </tr>');

    */
    htp.print('     </table>');
    htp.print('   </td>');
    htp.print(' </tr>');

    htp.print('  <tr>');
    htp.print('  </td>');
    htp.print('  </tr>');
    htp.print('  </tr>');
    htp.print('  </table>');
    /*
    htp.print('<table width="100%" align="center"  border="0" cellpadding="0" cellspacing="0">');
    htp.print('  <tr>');

    htp.print('    <td height="1" align="center" valign="top" bgcolor="#CCCCCC"></td>');
    htp.print('  </tr>');
    htp.print('</table>');
    */
END; --Procedure header

PROCEDURE footer  IS
    v_pathdad  VARCHAR2(100 char) := PDK.check_pathdad;
BEGIN
    htp.print('  <table width="100%" align="left" bgcolor="#285A83"  border="0" align="left" cellpadding="0" cellspacing="0"  background="'||v_pathdad||'bg_app1.gif" >');
    htp.print(' <tr align="center">');
    --htp.print('   <td colspan="2" height="20" bgcolor="#003366"><img src="'||v_pathdad||'logotjs_mini.gif" >&nbsp;<font color="#FFFFFF" size="1">');
    htp.print('   <td colspan="2" height="20" bgcolor="#1963b7">&nbsp;<font color="#FFFFFF" size="1"  face="verdana">');

    htp.print('     Copyright@People Plus Software Co.,Ltd. Bangkok Thailand (2006)</font></td>');
    htp.print(' </tr>');
    htp.print(' </table>');
END; --Procedure footer

PROCEDURE error_page(p_code IN VARCHAR2,
                     p_lang IN VARCHAR2) IS
     v_pathdad     VARCHAR2(100 char) := PDK.check_pathdad;
     v_desc        VARCHAR2(1000 char);
BEGIN
    v_desc := p_code ;--replace(PDK.error_table('TUSRPROF',p_code,p_lang),p_code,NULL) ;
    htp.print('<HTML>');
    htp.print('<HEAD>');

    htp.print('<TITLE>Change the URL</TITLE>');
    htp.print('<SCRIPT LANGUAGE="JavaScript">');
    htp.print('function check_index() {');
    htp.print('window.close();');
    htp.print('}');
    htp.print('</script>');
    htp.print('</head>');
    htp.print('<body leftmargin="0" topmargin="0" onUnload="check_index()">');
    htp.print('<link rel="stylesheet" href="'||v_pathdad||'StyleSh.css" type="text/css">');
    htp.print('<form name="form1"><table width="400" height="110" align="center" border="1" cellpadding="0" cellspacing="0" bgcolor="#DFE8EE" bordercolor="#8FABC2">');
    htp.print('     <tr>');
    htp.print('       <td  align="center" valign="middle" class="TextBodyHead"> ');
    htp.print('<br><table width="100%" align="center"  border="0" cellspacing="2" cellpadding="2">');

    htp.print('    <tr> ');
    htp.print('    <td width="25%" align="right" ><img src="'||v_pathdad||'warning.gif" width="47" height="47" align="absmiddle" border="0" ></td>');
    htp.print('      <td class="TextBody" width="75%"><input name="msg" size="2" type="text" class="txtbox3" readonly value="'||p_code||'"><font color="#000000"><b>'||v_desc||'</b></font></td>');
    htp.print('    </tr>');
    htp.print('    <tr align="center" valign="baseline"> ');
    htp.print('      <td colspan="2"> ');
    htp.print('<button onClick="check_index()" class="Buttonx">Close</button>');
    htp.print('</td></tr>');
    htp.print('  </table></form>');
    htp.print('</body>');

END; -- Procedure error_page


PROCEDURE menu(  p_coduser IN VARCHAR2,
                 p_lang    IN VARCHAR2,
                 p_main    IN VARCHAR2,
                 p_wide    IN NUMBER,
                 p_high    IN NUMBER,
                 p_action  IN VARCHAR2,
                 p_type    IN VARCHAR2,
                 p_chkall  IN VARCHAR2,
                 p_codcomp  IN VARCHAR2,
                 p_dtest    IN VARCHAR2,
                 p_dteen    IN VARCHAR2,
                 p_staappr  IN VARCHAR2,
                 p_codempid IN VARCHAR2)IS


   v_pathdad    VARCHAR2(100 char) := check_pathdad;
   v_scroll    VARCHAR2(10 char) := 'auto';
   CURSOR c_menu IS
         SELECT  desappe,desappt,codapp
         FROM    tprocapp
         WHERE   codapp LIKE '%U'
         and     codproc in (select codproc from tusrproc where coduser = p_coduser and codproc like '%MS%' )
         ORDER BY  numseq1,numseq2,numseq3,numseq4;
BEGIN

    htp.print('<table  width="100%" height="81%"  border="0" cellpadding="1"  cellspacing="1" align="center">');
    htp.print('  <tr valign="top"> ');

    htp.print('    <td width="180" valign="top" align="right" class="menubgv10"><table  width="100%" border="0" cellpadding="0" cellspacing="0">');
    htp.print('     <tr>');
    htp.print('       <td valign="top">');
    htp.print('         <table  width="100%" height="100%" border="0" cellpadding="0" cellspacing="0" class="menuborder">');
    htp.print('             <tr width="200">');
    htp.print('             <td><img src="'||v_pathdad||'menu_appv10.gif" width="200" height="38"  ></td>');
    htp.print('             </tr>');
    htp.print('          <tr>');
    htp.print('           <td>');
    --htp.print('              <table  width="100%"  border="0" cellpadding="3" cellspacing="4">');
    htp.print('              <table  width="100%"  border="0" cellpadding="0" cellspacing="1">');
    FOR i IN c_menu LOOP
        htp.print('<tr class="menu"  onmouseover="this.style.backgroundColor=''C4D5E3'';"  onmouseout="this.style.backgroundColor='''';">');

        IF P_LANG = '102' THEN
           htp.print('<td align="left" width="308" height="35"  ><a href="javascript:submit_form('''||lower(i.codapp)||''')" style="text-decoration:none "><font color="FFFFFF" onMouseOver="this.style.color = ''#FF6600''"
                           onMouseOut="this.style.color = ''''">'||'&nbsp;'||i.desappt||'</font></a></td>');

        ELSE
            htp.print('<td align="left" width="308" height="35"><a href="javascript:submit_form('''||lower(i.codapp)||''')" style="text-decoration:none "><font color="FFFFFF" onMouseOver="this.style.color = ''#FF6600''"
                           onMouseOut="this.style.color = ''''">'||'&nbsp;'||i.desappe||'</font></a></td>');
        END IF;
        htp.print('            </tr>');
    END LOOP;
    htp.print('          </table></td></tr></table></td>');
    htp.print('        </tr></table>');
    htp.print('     <!--/////// End Menu //////  -->');


    htp.print('    </td>');
    htp.print('    <td align="center" valign="top">');
    IF  p_type IS NOT NULL THEN
        htp.print('      <table width="100%" height="90%" bgcolor="#FFFFFF" border="0" cellpadding="5" cellspacing="0">');
    ELSE
        htp.print('      <table width="100%" height="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">');
    END IF;
    htp.print('       <tr>');
    htp.print('        <td   valign="top" >');
    htp.print('  <!-- /////////////////////////  insert form /////////////////////////-->');
    htp.print('  <iframe  frameborder="0" name="main" width="100%" height="100%" src="'||p_main||'"  scrolling="auto"></iframe>');
    htp.print('       </td></tr>');

    htp.print(' <form name="menu" method="get" action="'||p_action||'">');
    -----Up date 14/03/2007 By Pratya -----
    IF p_type = 'M' THEN
            htp.print(' <table width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">');
            htp.print('     <tr valign="top" class="TextBody">');
            IF p_chkall = 'Y' THEN
                htp.print('<td width="301" align="center" valign="middle">');
                htp.print('<input type="checkbox"  name="flg"  class="chkbox" onClick="this.value=check_all(main.form1.chk)">');
                htp.print('<input type="text"  name="txt_all" class="txtall" readonly value="'||get_label_name('HRES6BUC1', p_lang,99)||'" size = "45">');

                if substr(p_action,1,7) = 'HRES63U' then
                htp.print('    <td align="left" >');
                htp.print('&nbsp;&nbsp;<a href="javascript:call_leave();"  style="text-decoration:none" onmouseover="window.status='''';return true;"> <img src='||v_pathdad||'bullet.gif width="17" height="17" border="0" align="top">');

                htp.print('<font color="#006699"  onMouseOver="this.style.color = ''#00CCFF'';window.status='''';return true;" onMouseOut="this.style.color = ''''" >'||get_label_name('HRES63UC6',p_lang,10)||' </font> </a>');
                htp.print('    </td >');
                end if;

                htp.print('<input type="hidden"  name="txt_label">');
                htp.print('</td>');
            ELSE
                htp.print('<td align="center" valign="top">');
                htp.print('<input type="hidden"  name="txt_label">');
                htp.print('<input type="hidden"  name="flg">');
                htp.print('<input type="hidden"  name="txt_all">');
            END IF;
            htp.print('<td align="center" valign="top">');

            IF p_chkall = 'N' THEN
                htp.print('            <input type="button" name="bu_main"  onClick="chk_value2(main.form1.chk);"  value="Approve" class="ButtonA">');
            ELSE
                htp.print('            <input type="button" name="bu_main"  onClick="chk_value1(main.form1.chk);"  value="Approve" class="ButtonA">');
            END IF;
            htp.print('<input name="p_app" type="hidden" value="'||p_action||'">');
            htp.print('         </td>');
            htp.print('     </tr>');
            htp.print(' </table>');
    ELSIF p_type = 'S' THEN
            htp.print(' <table width="100%"  border="0" align="center" cellpadding="0" cellspacing="2">');
            htp.print('     <tr valign="top" class="TextBody">');
            IF p_chkall = 'Y' THEN

                htp.print('<td width="301" align="center" valign="middle">');
                htp.print('<input type="checkbox"  name="flg"  class="chkbox" onClick="this.value=check_all(main.form1.chk)">');
                htp.print('<input type="text"  name="txt_all" class="txtall" readonly value="'||get_label_name('HRES6BUC1', p_lang,99)||'" size="50">');
                htp.print('</td>');
            ELSE
                htp.print('<td align="center" valign="top">');
                htp.print('<input type="hidden"  name="flg">');
                htp.print('<input type="hidden"  name="txt_all">');
            END IF;
            htp.print('<td align="center" valign="top">');
            IF p_chkall = 'N' THEN
                htp.print('<input name="p_app" type="hidden" value="'||p_action||'">');
                htp.print('<input type="button" name="bu_edit"  onClick="chk_value2(main.form1.chk,''S'');"  value="Edit" class="ButtonA">');

                htp.print('<input type="hidden" name="txt_label">');
            ELSE
                htp.print('<input type="button" name="bu_main"  onClick="chk_value2(main.form1.chk,''S'');"  value="Approve" class="ButtonA">');
            END IF;
            htp.print('         </td>');
            htp.print('     </tr>');
            htp.print(' </table>');
    ELSE
            htp.print('<input type="hidden"  name="txt_label">');
            htp.print('<input type="hidden"  name="p_app">');
            htp.print('<input type="hidden"  name="flg">');
            htp.print('<input type="hidden"  name="txt_all">');
            htp.print(' <table width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">');

            htp.print(' </table>');
    END IF;

/*    IF p_type = 'M' THEN
            htp.print(' <table width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">');
            htp.print('     <tr valign="top" class="TextBody">');
            IF p_chkall = 'Y' THEN
                htp.print('<td width="301" align="center" valign="middle">');
                htp.print('<input type="checkbox"  name="flg"  class="chkbox" onClick="this.value=check_all(main.form1.chk)">');
                htp.print('<input type="text"  name="txt_all" class="txtall" readonly value="'||get_label_name('HRES6BUC1', p_lang,99)||'">');
                htp.print('<input type="hidden"  name="txt_label">');
                htp.print('</td>');
            ELSE

                htp.print('<td align="center" valign="top">');
                htp.print('<input type="hidden"  name="txt_label">');
                htp.print('<input type="hidden"  name="flg">');
                htp.print('<input type="hidden"  name="txt_all">');
            END IF;
            htp.print('<td align="center" valign="top">');
            IF p_chkall = 'N' THEN
                htp.print('            <input type="button" name="bu_main"  onClick="chk_value2(main.form1.chk);"  value="Approve" class="ButtonA">');
            ELSE
                htp.print('            <input type="button" name="bu_main"  onClick="chk_value1(main.form1.chk);"  value="Approve" class="ButtonA">');
            END IF;
            htp.print('<input name="p_app" type="hidden" value="'||p_action||'">');
            htp.print('         </td>');

            htp.print('     </tr>');
            htp.print(' </table>');
    ELSIF p_type = 'S' THEN
            htp.print(' <table width="100%"  border="0" align="center" cellpadding="0" cellspacing="2">');
            htp.print('     <tr valign="top" class="TextBody">');
            IF p_chkall = 'Y' THEN
                htp.print('<td width="301" align="center" valign="middle">');
                htp.print('<input type="checkbox"  name="flg"  class="chkbox" onClick="this.value=check_all(main.form1.chk)">');
                htp.print('<input type="text"  name="txt_all" class="txtall" readonly value="'||get_label_name('HRES6BUC1', p_lang,99)||'">');
                htp.print('</td>');
            ELSE
                htp.print('<td align="center" valign="top">');
                htp.print('<input type="hidden"  name="flg">');

                htp.print('<input type="hidden"  name="txt_all">');
            END IF;
            htp.print('<td align="center" valign="top">');
            IF p_chkall = 'N' THEN
                htp.print('<input name="p_app" type="hidden" value="'||p_action||'">');
                htp.print('<a href="javascript:chk_value2(main.form1.chk,''S'');" style="text-decoration:none" onMouseOver="document.menu.txt_label.style.color = ''#00CCFF'';bullet1.src='''||v_pathdad||'bullet_r.gif''" onMouseOut="document.menu.txt_label.style.color = '''';bullet1.src='''||v_pathdad||'bullet.gif''"> <img name="bullet1" src='||v_pathdad||'bullet.gif width="17" height="17" border="0" align="middle">');
                htp.print('<input name="txt_label" type="text" class="txt_label" onClick="chk_value2(main.form1.chk,''S'');" onMouseOver="this.style.color = ''#00CCFF'';this.style.cursor=''pointer'';bullet1.src='''||v_pathdad||'bullet_r.gif''" size="38" onMouseOut="this.style.color = '''';bullet1.src='''||v_pathdad||'bullet.gif''" value="'||get_label_name('HRES3CUC1', p_lang, 70)||'"></a>');
            ELSE
                htp.print('<input type="button" name="bu_main"  onClick="chk_value2(main.form1.chk,''S'');"  value="Approve" class="ButtonA">');
            END IF;
            htp.print('         </td>');
            htp.print('     </tr>');
            htp.print(' </table>');

    ELSE
            htp.print('<input type="hidden"  name="txt_label">');
            htp.print('<input type="hidden"  name="p_app">');
            htp.print('<input type="hidden"  name="flg">');
            htp.print('<input type="hidden"  name="txt_all">');
            htp.print(' <table width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">');
            htp.print(' </table>');
    END IF;*/
    htp.print('    <tr>');

    htp.print('<input name="p_code"    type="hidden">');
    htp.print('<input name="p_codcomp" type="hidden" value="'||p_codcomp||'">');
    htp.print('<input name="p_dtest"   type="hidden" value="'||p_dtest||'">');

    htp.print('<input name="p_dteen"   type="hidden" value="'||p_dteen||'">');
    htp.print('<input name="p_staappr" type="hidden" value="'||p_staappr||'">');
    htp.print('<input name="p_codempid" type="hidden" value="'||p_codempid||'">');
    htp.print('<input name="p_coduser" type="hidden" value="'||p_coduser||'">');
    htp.print('<input name="p_lang"    type="hidden" value="'||p_lang||'">');
    htp.print('</form>');
    htp.print('<td>');
    htp.print('</td>');
    htp.print('    </tr>');
    htp.print('    </table></td>');
EXCEPTION
  WHEN others THEN
      PDK.error_page('2020',p_lang);

END; -- Procedure Menu


FUNCTION check_seq(p_chk IN VARCHAR2,p_approvno IN NUMBER
          ,p_chk_seq IN VARCHAR2) RETURN BOOLEAN IS
v_return BOOLEAN ;
BEGIN
    v_return := TRUE ;
  IF p_chk_seq = 'Y' THEN
      IF  p_chk <> 'E' THEN
          IF p_approvno >= to_number(p_chk) THEN
             v_return :=  FALSE ;
          END IF;

      END IF;
  END IF;
  RETURN v_return ;
END; --FUNCTION check_seq

FUNCTION check_pathdad RETURN VARCHAR2  IS
   v_web VARCHAR2(200 char);
BEGIN
    SELECT value
    INTO v_web
    FROM tsetup
    where codvalue ='PATHPDK' ;
         RETURN  v_web ;

END; -- FUNCTION  check_pathdad

FUNCTION check_codempid(p_coduser IN VARCHAR2) RETURN VARCHAR2  IS
  v_codempid VARCHAR2(100 char);
BEGIN
 BEGIN
    SELECT codempid INTO v_codempid
    FROM tusrprof
    WHERE coduser = p_coduser;
 EXCEPTION WHEN others THEN
    NULL;
 END ;
    RETURN  v_codempid ;

END;  --FUNCTION Check_Codempid

FUNCTION Sendmail (p_codempid IN VARCHAR2,p_codapp IN VARCHAR2,
                               p_typemail IN VARCHAR2,p_item_err IN VARCHAR2,
                               p_approv_no IN NUMBER,p_approv IN VARCHAR2,p_lang IN VARCHAR2) RETURN VARCHAR2 IS

    p_msg_to      varchar2(4000 char);
    p_msg_cc      varchar2(4000 char);
    msg_error     varchar2(4 char);
    data_file     varchar2(7000 char);
    v_text        varchar2(20);
    linebuf       varchar2(6000 char);
    v_codempid    varchar2(20 char);

    v_namfile     varchar2(150 char) := null;
    v_error       number;
    crlf          varchar2( 2 ):= chr( 13 ) || chr( 10 );
    v_coduser     varchar2(20 char);
    v_codpswd     varchar2(20 char);
    v_id          varchar2(20 char);
    v_http        varchar2(500 char);
    v_pathwork    varchar2(1000 char);
    v_codapp      varchar2(10 char);
  ----------------------------------------------------------
BEGIN
    --Get ????????????
       BEGIN

                SELECT value
                INTO   v_pathwork
                FROM   tsetup
                  where codvalue ='PATHWORK';
        EXCEPTION WHEN no_data_found THEN
                    v_pathwork := NULL;
        END;
        BEGIN
                SELECT value
                INTO   v_http
                FROM   tsetup
                where codvalue ='PATHPORTAL';
        EXCEPTION WHEN no_data_found THEN

                    v_pathwork := NULL;
        END;
        /*  BEGIN
                SELECT namfile INTO v_namfile
                FROM   tfrmmail
                WHERE  codapp  = p_codapp
                AND    seqno   = p_typemail;
                AND    codlang = p_lang ;
            EXCEPTION WHEN no_data_found THEN
                v_namfile  := NULL;
            END;
      /*
    IF get_application_property(operating_system) LIKE '%WIN%' THEN

      v_namfile := v_pathwork||'\forms\'||v_namfile;
    ELSE
      v_namfile := v_pathwork||'/forms/'||v_namfile;
    END IF;
      v_error := check_file.text_read(v_namfile);
      IF v_error IS NOT  NULL THEN
         RETURN('5013');
      END IF;

        in_file  := Text_IO.Fopen(v_namfile, 'r');  --File read
      --:parameter.v_message    := null ;
      --:parameter.v_cc_message := null ;
    NULL ;

        LOOP
            Text_IO.Get_Line(in_file, linebuf);
          --:parameter.v_message    := :parameter.v_message ||crlf||linebuf;
          IF linebuf NOT LIKE ('%<HTTP>%') THEN
            --:parameter.v_cc_message := :parameter.v_cc_message ||crlf||linebuf;
        NULL;
          ELSE
            --:parameter.v_cc_message := :parameter.v_cc_message ||crlf||' ';
                NULL;
          END IF;
        END LOOP;

        Text_IO.Fclose(in_file);

        EXCEPTION   WHEN no_data_found THEN
         Text_IO.Fclose(in_file);

    set_application_property(cursor_style,'busy');
    replace_text(p_msg_to,'TO','');
    replace_text(p_msg_cc,'CC','');
    */
--  workflow.send_mail_to_approve(p_codempid,p_approv,p_codapp,p_approv_no,p_msg_to,p_msg_cc,p_lang,msg_error);

  IF msg_error  IS NOT NULL THEN
       IF msg_error = '7521' THEN
        RETURN('2402');
       ELSE

        RETURN('2403');
       END IF;
    ELSE
        RETURN('2404');
  END IF;
END; -- FUNCTION Sendmail

FUNCTION check_year(p_lang IN VARCHAR2) RETURN NUMBER IS
 v_return    number ;
 v_calendar  varchar2(100 char);
BEGIN
    SELECT VALUE
    INTO   v_calendar

    FROM   v$nls_parameters
    WHERE  parameter = 'NLS_CALENDAR';

     IF upper(v_calendar) = 'THAI BUDDHA' THEN
        v_return  := 543 ;
     ELSE
        v_return  := 0 ;
     END IF;
     RETURN v_return;
END; -- FUNCTION Check_Year

--FUNCTION error_msg(p_coderr IN NUMBER,p_lang IN VARCHAR2)
FUNCTION error_msg(p_coderr IN VARCHAR2,p_lang IN VARCHAR2)

                             RETURN VARCHAR2 IS

 CURSOR c_terror IS
       SELECT errorno,descripe,descript,descrip3,descrip4,descrip5
         FROM terrorm
        WHERE errorno = p_coderr
          AND ROWNUM <= 1;
 v_msg    varchar2(200 char);
 rec_tmsg c_terror%ROWTYPE;
BEGIN
      OPEN c_terror;
      FETCH c_terror INTO rec_tmsg;
          IF p_lang = '101' THEN
              v_msg := rec_tmsg.errorno||' '||rec_tmsg.descripe;
          ELSIF p_lang = '102' THEN
              v_msg := rec_tmsg.errorno||' '||rec_tmsg.descript;
          ELSIF p_lang = '103' THEN
              v_msg := rec_tmsg.errorno||' '||rec_tmsg.descrip3;
          ELSIF p_lang = '104' THEN
              v_msg := rec_tmsg.errorno||' '||rec_tmsg.descrip4;

          ELSIF p_lang = '105' THEN
              v_msg := rec_tmsg.errorno||' '||rec_tmsg.descrip5;
          END IF;
       CLOSE c_terror;

  RETURN v_msg;
END;

FUNCTION error_table(p_table  IN VARCHAR2 ,
                     p_coderr IN VARCHAR2,
                     p_lang   IN VARCHAR2) RETURN VARCHAR2 IS

CURSOR c0 IS
       SELECT errorno,descripe,descript,descrip3,descrip4,descrip5
         FROM terrorm
        WHERE errorno = p_coderr;

  CURSOR c2 IS
        SELECT comments
        FROM  user_tab_comments
        WHERE TABLE_NAME  = UPPER(p_table);
  rec_c0        c0%rowtype;
  v_desc        varchar2(150 char) := null;
  v_alert       number;

BEGIN
        OPEN c0;
        FETCH c0 INTO rec_c0;
            IF p_lang = '101' THEN
                v_desc := rec_c0.descripe;

            ELSIF p_lang = '102' THEN
                v_desc := rec_c0.descript;
            ELSIF p_lang = '103' THEN
                v_desc := rec_c0.descrip3;
            ELSIF p_lang = '104' THEN
                v_desc := rec_c0.descrip4;
            ELSIF p_lang = '105' THEN
                v_desc := rec_c0.descrip5;
            END IF;
         CLOSE c0;

    FOR i IN c2 LOOP
         v_desc     := v_desc || '<br>' ||i.comments ;
    END LOOP;
    v_desc    := v_desc ||' ('|| upper(p_table) ||')';
    RETURN    p_coderr||' '||v_desc;

END;

PROCEDURE login IS
v_pathdad  varchar2(100 char) := pdk.check_pathdad;
BEGIN
    htp.print('<html>');
    htp.print('<head>');
    htp.print('<title>  Human Resource Management System V.10g  </title>');
    htp.print('<link rel="stylesheet" href="'||v_pathdad||'StyleSh.css" type="text/css">');
    htp.print('</head>');
    htp.print('<body background="'||v_pathdad||'bgbg.gif"  bgcolor=#ffffff leftmargin=0 topmargin=0 marginwidth=0 marginheight=0>');
    htp.print('<form action="PDK.test">');

    htp.print('<table  align="center"  width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">');
    htp.print('<tr>');
    htp.print('<td  valign="middle">');
    htp.print('<table  align="center"  width=774 border=0 cellpadding=0 cellspacing=0 bgcolor="#ffffff">');
    htp.print('<tr><td><img src="'||v_pathdad||'hrms10g_crop1_01.gif"  width=172 height=189></td>');
    htp.print('<td><img src="'||v_pathdad||'hrms10g_crop1_02.gif"  width=215 height=189></td>');
    htp.print('<td><img src="'||v_pathdad||'hrms10g_crop1_03.gif"  width=179 height=189></td>');
    htp.print('<td colspan="2"><img src="'||v_pathdad||'hrms10g_crop1_04.gif"  width=208 height=189></td></tr>');
    htp.print('<tr><td align="right" rowspan="2"  width="172" height="158" background="'||v_pathdad||'hrms10g_crop1_05.gif">');
    /*
    htp.print('<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=5,0,0,0" width="152" height="152">');
    htp.print('<param name=movie value="'||v_pathdad||'logo.swf">');
    htp.print('<param name=quality value=high>');

    htp.print('<param name="wmode" value="transparent">');
    htp.print('</object></td>');
    */
    htp.print('<td rowspan="2" colspan="2"><img src="'||v_pathdad||'hrms10g_crop1_06.gif"  width=394 height=158></td>');
    htp.print('<td colspan="2"><img src="'||v_pathdad||'hrms10g_crop1_07.gif"  width=208 height=63></td></tr>');
    htp.print('<tr><td colspan="2"  height="95"><table   width="100%" border="0" cellspacing="1" cellpadding="1">');
    htp.print('<tr><td><input type="text" name="username" value="tjs01" class="txtbox2"></td></tr>');
    htp.print('<tr><td  height="33"><input type="password"  name="password" value="11111" class="txtbox2"></td></tr>');
    htp.print('<tr><td><select name="select" class="DropDown">');
    htp.print('<option selected  value="101" >....english.... <option  value="102">....thai....</select></td></tr>');
    htp.print('</table></td></tr>');
    htp.print('<tr><td colspan="2"><img src="'||v_pathdad||'hrms10g_crop1_09.gif"  width=387 height=70></td>');
    htp.print('<td colspan="3"  height="70" background="'||v_pathdad||'hrms10g_crop1_10.gif">');

    htp.print('<table   width="100%" border="0" cellspacing="0" cellpadding="0">');
    htp.print('<tr><td  width="45%">&nbsp;</td><td><input name ="txtsave" type="button"  class="ButtonA"  value="Login" onClick="parent.location.href=''main.main?p_coduser=TJS01&p_lang=102''"></td></tr>');
    htp.print('<tr><td colspan="2">&nbsp;</td></tr><tr><td colspan="2">&nbsp;</td></tr></table></td></tr>');
    htp.print('<tr><td colspan="2"><img src="'||v_pathdad||'hrms10g_crop1_11.gif"  width=387 height=64></td>');
    htp.print('<td colspan="3"><img src="'||v_pathdad||'hrms10g_crop1_12.gif"  width=387 height=64></td></tr>');
    htp.print('<tr><td colspan="2"><img src="'||v_pathdad||'hrms10g_crop1_13.gif"  width=387 height=40></td>');
    htp.print('<td colspan="3"><img src="'||v_pathdad||'hrms10g_crop1_14.gif"  width=387 height=40></td></tr>');
    htp.print('<tr><td colspan="2"><img src="'||v_pathdad||'hrms10g_crop1_15.gif"  width=387 height=46></td>');
    htp.print('<td colspan="2"><img src="'||v_pathdad||'hrms10g_crop1_16.gif"  width=381 height=46></td>');
    htp.print('<td><img src="'||v_pathdad||'hrms10g_crop1_17.gif"  width=6 height=46></td></tr>');
    htp.print('<tr><td><img src="'||v_pathdad||'spacer.gif"  width=172 height=1></td>');
    htp.print('<td><img src="'||v_pathdad||'spacer.gif"  width=215 height=1></td>');
    htp.print('<td><img src="'||v_pathdad||'spacer.gif"  width=179 height=1></td>');

    htp.print('<td><img src="'||v_pathdad||'spacer.gif"  width=202 height=1></td>');
    htp.print('<td><img src="'||v_pathdad||'spacer.gif"  width=6 height=1></td></tr></table></td>');
    htp.print('</tr>');
    htp.print('</table>');
    htp.print('</body>');
    htp.print('</html>');
END;

PROCEDURE get_list_item(p_code  IN VARCHAR2,
                        p_lang  IN VARCHAR2,
                        p_item  IN VARCHAR2,
                        p_value IN VARCHAR2,
                        p_style IN VARCHAR2) IS

CURSOR c_list_value IS
        SELECT   codlang,desc_label,list_value
        FROM     tlistval
        WHERE    codapp  = p_code
        AND      codlang = p_lang
        AND      numseq > 0
        ORDER BY codapp,codlang,numseq;
BEGIN
htp.p('<select name="'||p_item||'" class="'||p_style||'"  onchange="document.form1.'||p_item||'.style.background =''#FFFFFF'';">');
FOR i IN c_list_value LOOP
  IF i.list_value = p_value THEN
     htp.p('<option value="'||i.list_value||'" size="8" selected >'||i.desc_label||'</option>');
  ELSE

     htp.p('<option value="'||i.list_value||'" size="8" >'||i.desc_label||'</option>');
  END IF;
END LOOP;
htp.p('</select>');
END;

PROCEDURE get_tinexinf(p_item  IN VARCHAR2,
                       p_type  IN VARCHAR2,
                       p_lang  IN VARCHAR2) IS
CURSOR c_get_tinexinf IS
        SELECT codpay,descpaye,descpayt,descpay3,descpay4,descpay5
          FROM tinexinf
        ORDER BY codpay ;

BEGIN
htp.p('<select name="'||p_item||'" class="DropDownMid">');
FOR i IN c_get_tinexinf LOOP
  IF p_lang = '101' THEN
     htp.p('<option value="'||i.codpay||'" size="8" >'||i.codpay||'-'||i.descpaye||'</option>');
  ELSIF p_lang = '102' THEN
     htp.p('<option value="'||i.codpay||'" size="8" >'||i.codpay||'-'||i.descpayt||'</option>');
  ELSIF p_lang = '103' THEN
     htp.p('<option value="'||i.codpay||'" size="8" >'||i.codpay||'-'||i.descpay3||'</option>');
  ELSIF p_lang = '104' THEN
     htp.p('<option value="'||i.codpay||'" size="8" >'||i.codpay||'-'||i.descpay4||'</option>');
  ELSIF p_lang = '105' THEN
     htp.p('<option value="'||i.codpay||'" size="8" >'||i.codpay||'-'||i.descpay5||'</option>');

  END IF;
END LOOP;
htp.p('</select>');
END;

PROCEDURE get_tcodmove(p_item  IN VARCHAR2,
                       p_type  IN VARCHAR2,
                       p_lang  IN VARCHAR2) IS
CURSOR c_get_tcodmove IS
        SELECT codcodec,descode,descodt,descod3,descod4,descod5
          FROM tcodmove
        ORDER BY codcodec ;
BEGIN

htp.p('<select name="'||p_item||'" class="DropDownMid">');
FOR i IN c_get_tcodmove LOOP
  IF p_lang = '101' THEN
     htp.p('<option value="'||i.codcodec||'" size="8" >'||i.codcodec||'-'||i.descode||'</option>');
  ELSIF p_lang = '102' THEN
     htp.p('<option value="'||i.codcodec||'" size="8" >'||i.codcodec||'-'||i.descodt||'</option>');
  ELSIF p_lang = '103' THEN
     htp.p('<option value="'||i.codcodec||'" size="8" >'||i.codcodec||'-'||i.descod3||'</option>');
  ELSIF p_lang = '104' THEN
     htp.p('<option value="'||i.codcodec||'" size="8" >'||i.codcodec||'-'||i.descod4||'</option>');
  ELSIF p_lang = '105' THEN
     htp.p('<option value="'||i.codcodec||'" size="8" >'||i.codcodec||'-'||i.descod5||'</option>');
  END IF;

END LOOP;
htp.p('</select>');
END;


PROCEDURE pass_approve( p_codapp   VARCHAR2,
                        p_coduser  VARCHAR2,
                        p_lang     VARCHAR2,
                        p_codcomp  VARCHAR2,
                        p_dtest    VARCHAR2,
                        p_dteen    VARCHAR2,
                        p_staappr  VARCHAR2,
                        p_codempid VARCHAR2) IS


    v_pathdad     varchar2(200 char) := pdk.check_pathdad;
BEGIN
    htp.print('<HTML>');
    htp.print('<HEAD>');
    htp.print('<TITLE>______________:::. Employee Self Service .:::_________________</TITLE>');
    htp.print('<SCRIPT LANGUAGE="JavaScript">');
    htp.print('function check_index() {');
    htp.print('dialogArguments.location.href = "'||p_codapp||'.'||p_codapp||'?p_coduser='||p_coduser||'&p_lang='||p_lang||'&p_codcomp='||p_codcomp||'&p_dtest='||p_dtest||'&p_dteen='||p_dteen||'&p_staappr='||p_staappr||'&p_codempid='||p_codempid||'&p_page=1";'); -- Back To Main if Complete.
    --htp.print('dialogArguments.location.href = "'||p_codapp||'.'||p_codapp||'?p_coduser='||p_coduser||'&p_lang='||p_lang||'";'); -- Back To Main if Complete.
    htp.print('window.close();');
    htp.print('}');
    htp.print('function auto_page() {');

    htp.print('    setTimeout("check_index()",2000);');
    htp.print('}');
    htp.print('</script>');
    htp.print('</head>');
    htp.print('<body leftmargin="0" onLoad="auto_page()" topmargin="0" onUnload="check_index()">');
    htp.print('<link rel="stylesheet" href="'||v_pathdad||'StyleSh.css" type="text/css">');
    htp.print('   <table width="400" height="124" border="1" cellpadding="0" cellspacing="0" bgcolor="#DFE8EE" bordercolor="#8FABC2">');
    htp.print('     <tr>');
    htp.print('       <td height="88"  align="center" valign="middle" class="TextBodyHead"> ');
    htp.print('<br><table width="80%" align="center"  border="0" cellspacing="2" cellpadding="2">');
    htp.print('    <tr> ');
    htp.print('    <td width="30%" align="right" ><img src="'||v_pathdad||'warning.gif" width="47" height="47" align="absmiddle" border="0" ></td>');
    htp.print('      <td class="TextBody" width="70%"><input name="msg" size="20" type="text" class="txtbox4" readonly value=" Approve Complete.. !! "></td>');

    htp.print('    </tr>');
    htp.print('    <tr align="center" valign="baseline"> ');
    htp.print('      <td height="25" colspan="2" > ');
    htp.print('<button onClick="check_index()" class="Buttonx">Close</button>');
    htp.print('</td></tr>');
    htp.print('  </table>');
    htp.print('</body>');
END; -- Procedure

PROCEDURE error_approve(p_code  IN VARCHAR2,
                p_table IN VARCHAR2,
                p_item  IN VARCHAR2,
                p_lang  IN VARCHAR2 ) IS

     v_pathdad     varchar2(2000 char) := check_pathdad;
     v_desc        varchar2(2000 char);
BEGIN
    IF p_table IS  NULL THEN
        v_desc := replace(PDK.error_msg(p_code,p_lang),p_code,NULL) ;
    ELSE
        v_desc := replace(PDK.error_table(p_table,p_code,p_lang),p_code,NULL) ;
    END IF;
    htp.print('<HTML>');
    htp.print('<HEAD>');
    htp.print('<TITLE>______________:::. Employee Self Service .:::______________</TITLE>');
    htp.print('<SCRIPT LANGUAGE="JavaScript">');
    htp.print('function check_index() {');

    htp.print('dialogArguments.form1.'||p_item||'.style.background = "#F09A9C";');
    htp.print('dialogArguments.form1.'||p_item||'.focus();');
    htp.print('window.close();');
    htp.print('}');
    htp.print('function auto_page() {');
    htp.print('setTimeout("check_index()",2000);');
    htp.print('}');
    htp.print('</script>');
    htp.print('</head>');
    htp.print('<body leftmargin="0" onLoad="auto_page()" topmargin="0" onUnload="check_index()">');
    htp.print('<link rel="stylesheet" href="'||v_pathdad||'StyleSh.css" type="text/css">');
    htp.print('<form name="form1"><table width="400" height="110" align="center" border="1" cellpadding="0" cellspacing="0" bgcolor="#DFE8EE" bordercolor="#8FABC2">');
    htp.print('     <tr>');

    htp.print('       <td  align="center" valign="middle" class="TextBodyHead"> ');
    htp.print('<br><table width="100%" align="center"  border="0" cellspacing="2" cellpadding="2">');
    htp.print('    <tr> ');
--    htp.print('    <td width="25%" align="right" ><img src="'||v_pathdad||'warning.gif" width="47" height="47" align="absmiddle" border="0" ></td>');
    htp.print('    <td width="20%" align="right" ><img src="'||v_pathdad||'warning.gif" width="47" height="47" align="absmiddle" border="0" ></td>');
--    htp.print('      <td class="TextBody" width="75%"><input name="msg" size="2" type="text" class="txtbox3" readonly value="'||p_code||'"><font color="#000000"><b>'||v_desc||'</b></font></td>');
    htp.print('      <td class="TextBody" width="80%"><input name="msg" size="5" type="text" class="txtbox3" readonly value="'||p_code||'" style="text-align:center"><font color="#000000"><b>'||v_desc||'</b></font></td>');
    htp.print('    </tr>');
    htp.print('    </table>');
    htp.print('<table width="100%" align="center"  border="0" cellspacing="2" cellpadding="2">');
    htp.print('    <tr align="center" valign="baseline"> ');
    htp.print('      <td colspan="2"> ');
    htp.print('<button onClick="check_index()" class="Buttonx">Close</button>');

    htp.print('</td></tr>');
    htp.print('  </table></form>');
    htp.print('</body>');
    htp.print('</HTML>');
END; -- Procedure error_approve


--PROCEDURE get_tcodplan(p_item  IN VARCHAR2,
--                       p_type  IN VARCHAR2,
--                       p_lang  IN VARCHAR2) IS
--CURSOR c_tplaninf IS
--        SELECT codplan,desplane,desplant,desplan3,desplan4,desplan5
--          FROM tplaninf
--
--        ORDER BY codplan ;
--BEGIN
--htp.p('<select name="'||p_item||'" class="DropDownMid">');
--htp.p('<option value="" size="8" > </option>');
--FOR i IN c_tplaninf LOOP
--  IF p_lang = '101' THEN
--     htp.p('<option value="'||i.codplan||'" size="8" >'||i.codplan||'-'||i.desplane||'</option>');
--  ELSIF p_lang = '102' THEN
--     htp.p('<option value="'||i.codplan||'" size="8" >'||i.codplan||'-'||i.desplant||'</option>');
--  ELSIF p_lang = '103' THEN
--     htp.p('<option value="'||i.codplan||'" size="8" >'||i.codplan||'-'||i.desplan3||'</option>');
--  ELSIF p_lang = '104' THEN
--     htp.p('<option value="'||i.codplan||'" size="8" >'||i.codplan||'-'||i.desplan4||'</option>');
--
--  ELSIF p_lang = '105' THEN
--     htp.p('<option value="'||i.codplan||'" size="8" >'||i.codplan||'-'||i.desplan5||'</option>');
--  END IF;
--END LOOP;
--htp.p('</select>');
--END;  -- get_tcodplan

procedure get_tlistval(p_item    in varchar2,
                       p_codapp  in varchar2,
                       p_lang    in varchar2) is
cursor c1 is
        select codapp,codlang,desc_label,list_value
          from tlistval

         where codapp  = upper(p_codapp)
           and codlang = p_lang
           and numseq  <> 0
        order by numseq ;
begin
htp.p('<select name="'||p_item||'" class="dropdownmid">');
htp.p('<option value="" size="5" > </option>');
for i in c1 loop
  if p_lang = '101' then
     htp.p('<option value="'||i.list_value||'" size="5" >'||i.desc_label||'</option>');
  elsif p_lang = '102' then
     htp.p('<option value="'||i.list_value||'" size="5" >'||i.desc_label||'</option>');
  elsif p_lang = '103' then

     htp.p('<option value="'||i.list_value||'" size="5" >'||i.desc_label||'</option>');
  elsif p_lang = '104' then
     htp.p('<option value="'||i.list_value||'" size="5" >'||i.desc_label||'</option>');
  elsif p_lang = '105' then
     htp.p('<option value="'||i.list_value||'" size="5" >'||i.desc_label||'</option>');
  end if;
end loop;
htp.p('</select>');
end;  -- get_tlistval

PROCEDURE error_process(p_code VARCHAR2,
                        p_table VARCHAR,
                        p_item VARCHAR2,

                        p_lang VARCHAR2
                        ) IS
BEGIN
    htp.print('<HTML>');
    htp.print('<HEAD>');
    htp.print('<TITLE>Change the URL</TITLE>');

    --<< include main javascript
    pdk.include_js ;
    -->> include main javascript

    htp.print('<SCRIPT LANGUAGE="JavaScript">');
    htp.print('function auto_page() {');

    htp.print('window.close();');
    htp.print('}');

    htp.print('function auto_send() {');
    htp.print('var v_param = "p_code='||p_code||'&p_table='||p_table||'&p_item='||p_item||'&p_lang='||p_lang||'" ');
    htp.print('var winsize   = "dialogHeight:149px;dialogWidth:406px;help:no;status:no;";');
    htp.print('window.showModalDialog("PDK.error_approve?"+v_param,window,winsize);');
    htp.print('}');

    htp.print('</script>');
    htp.print('</head>');
    htp.print('<body leftmargin="0" onLoad="auto_page()" topmargin="0" onUnload="auto_send()">');
    htp.print('</body>');


END; -- Procedure error_approve

procedure Main_Data(p_label1 in varchar2,
                    p_link1  in varchar2,
                    p_label2 in varchar2,
                    p_link2  in varchar2,
                    p_label3 in varchar2,
                    p_link3  in varchar2,
                    p_label4 in varchar2,
                    p_link4  in varchar2,
                    p_label5 in varchar2,
                    p_link5  in varchar2,
                    p_label6 in varchar2,
                    p_link6  in varchar2,
                    p_label7 in varchar2,
                    p_link7  in varchar2,
                    p_label8 in varchar2 default null,
                    p_link8  in varchar2 default null)  is
                    --user36 STA3590329 01/11/2016 add tab 8
                    --user36 STA3600369 31/03/2017 add default null

    v_pathdad  varchar2(100 char) := pdk.check_pathdad;
begin
    htp.print('<html>');
    htp.print('<head>');
    htp.print('<title>:. Employee Self Service .:</title>');
    htp.print('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">');
    htp.print('<link href="'||v_pathdad||'<%=StyleCalendar%>" rel="stylesheet" type="text/css" media=all title=win2k-1>');
    htp.print('<link rel="stylesheet" href="'||v_pathdad||'bingo.css" type="text/css">');
    htp.print('<SCRIPT LANGUAGE="JavaScript">');

    htp.print('function dis_red() {');
    htp.print('document.getElementById("p_link1").style.color = ''#000000'';');
    if ltrim(p_link2) is not null then
    htp.print('document.getElementById("p_link2").style.color = ''#000000'';');
    end if;
    if ltrim(p_link3) is not null then
    htp.print('document.getElementById("p_link3").style.color = ''#000000'';');
    end if;
    if ltrim(p_link4) is not null then
    htp.print('document.getElementById("p_link4").style.color = ''#000000'';');
    end if;
    if ltrim(p_link5) is not null then
    htp.print('document.getElementById("p_link5").style.color = ''#000000'';');
    end if;
    if ltrim(p_link6) is not null then
    htp.print('document.getElementById("p_link6").style.color = ''#000000'';');
    end if;
    if ltrim(p_link7) is not null then
    htp.print('document.getElementById("p_link7").style.color = ''#000000'';');
    end if;
    if ltrim(p_link8) is not null then
    htp.print('document.getElementById("p_link8").style.color = ''#000000'';');
    end if;
    htp.print('}');
    htp.print('</SCRIPT>');
    htp.print('</head>');
    htp.print('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">');
    htp.print('   <table cellpadding="0" cellspacing="0" border="0" width="100%" height="50">');
    htp.print('    <tr height="60">');

    htp.print('      <td>');
    --htp.print('      <td background="'||v_pathdad||'head_l2.gif">');
    htp.print('        <table width="100%" height="60" border="0" cellpadding="0" cellspacing="0">');
    htp.print('          <tr>');
    htp.print('            <td width="195" height="48" align="center" background="'||v_pathdad||'head_l2.gif"></td>');
    htp.print('            <td width="465" height="48" align="center" background="'||v_pathdad||'head_l3.gif"></td>');
    htp.print('            <td background="'||v_pathdad||'head_essr.gif">&nbsp;</td>');
    htp.print('          </tr>');
    htp.print('          <tr>');
    htp.print('            <td width="195" height="15"><img src="'||v_pathdad||'head_ess.gif"></td>');
    htp.print('            <td width="465" height="15" class="Textbody" background="'||v_pathdad||'head_title_m.gif" valign="bottom"></td>');
    htp.print('            <td background="'||v_pathdad||'head_u_essr.gif">&nbsp;</td>');
    htp.print('          </tr>');

/*
    htp.print('          <tr>');
    htp.print('            <td width="18%" align="center">');
    htp.print('              <table width="74" border="0" cellspacing="0" cellpadding="0">');
    htp.print('                <tr>');
    htp.print('                </tr>');
    htp.print('              </table>');
    htp.print('            </td>');
    htp.print('            <td width="9%">');
    htp.print('              <table width="63" border="0" cellspacing="0" cellpadding="0">');
    htp.print('                <tr>');
    htp.print('                  <td align="center"><img src="'||v_pathdad||'s_bottom.gif" width="262" height="50"></td>');
    htp.print('                </tr>');

    htp.print('              </table>');
    htp.print('            </td>');
    htp.print('          </tr>');
*/
    htp.print('        </table>');
    htp.print('      </td>');
    htp.print('    </tr>');


    htp.print('    <tr height="22">');
    htp.print('      <td >');
    htp.print('  <table width="100%" height="22" border="0" cellpadding="0" cellspacing="1" >');
    htp.print('  <tr height="22">');

    htp.print('    <td background="'||v_pathdad||'tab_bg.gif">');
    htp.print('      <table height="22"  border="0" cellpadding="0" cellspacing="0" >');
    htp.print('        <tr id="www" >');
    htp.print('          <td background="'||v_pathdad||'tab_left.gif">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>');
    if p_link1 is not null then
        htp.print('<td background="'||v_pathdad||'tab.gif" class="TextBody">');
        htp.print('<a href="'||replace(replace(p_link1,'$','?'),'!','&')||'" target="content" ><font id="p_link1" color="#FF6600" onClick="dis_red();this.style.color = ''#FF6600''" > &nbsp;&nbsp;'||p_label1||'</font></a></td>');
    end if;
    if ltrim(p_link2) is not null then
    htp.print('<td background="'||v_pathdad||'tab_center.gif" >&nbsp;&nbsp;&nbsp;</td><td align="center"  background="'||v_pathdad||'tab.gif" class="TextBody">');
    htp.print('<a href="'||replace(replace(p_link2,'$','?'),'!','&')||'" target="content" ><font  id="p_link2" color="#000000" onClick="dis_red();this.style.color = ''#FF6600''"  >&nbsp;&nbsp;'||p_label2||'</font></a></td>');
    end if;
    if ltrim(p_link3) is not null then
    htp.print('<td background="'||v_pathdad||'tab_center.gif">&nbsp;&nbsp;&nbsp;</td><td align="center"  background="'||v_pathdad||'tab.gif" class="TextBody">');
    htp.print('<a href="'||replace(replace(p_link3,'$','?'),'!','&')||'" target="content" ><font  id="p_link3" color="#000000" onClick="dis_red();this.style.color = ''#FF6600''"  >&nbsp;&nbsp;'||p_label3||'</font></a></td>');
    end if;
    if ltrim(p_link4) is not null then
    htp.print('<td background="'||v_pathdad||'tab_center.gif">&nbsp;&nbsp;&nbsp;</td><td align="center"  background="'||v_pathdad||'tab.gif" class="TextBody">');
    htp.print('<a href="'||replace(replace(p_link4,'$','?'),'!','&')||'" target="content"><font   id="p_link4"  color="#000000" onClick="dis_red();this.style.color = ''#FF6600''"  >&nbsp;&nbsp;'||p_label4||'</font></a></td>');
    end if;
    if ltrim(p_link5) is not null then
    htp.print('<td background="'||v_pathdad||'tab_center.gif">&nbsp;&nbsp;&nbsp;</td><td align="center"  background="'||v_pathdad||'tab.gif" class="TextBody">');
    htp.print('<a href="'||replace(replace(p_link5,'$','?'),'!','&')||'" target="content"><font  id="p_link5" color="#000000" onClick="dis_red();this.style.color = ''#FF6600''"  >&nbsp;&nbsp;'||p_label5||'</font></a></td>');
    end if;
    if ltrim(p_link6) is not null then
    htp.print('<td background="'||v_pathdad||'tab_center.gif">&nbsp;&nbsp;&nbsp;</td><td align="center"  background="'||v_pathdad||'tab.gif" class="TextBody">');
    htp.print('<a href="'||replace(replace(p_link6,'$','?'),'!','&')||'" target="content"><font  id="p_link6" color="#000000" onClick="dis_red();this.style.color = ''#FF6600''"  >&nbsp;&nbsp;'||p_label6||'</font></a></td>');
    end if;
    if ltrim(p_link7) is not null then
    htp.print('<td background="'||v_pathdad||'tab_center.gif">&nbsp;&nbsp;&nbsp;</td><td align="center"  background="'||v_pathdad||'tab.gif" class="TextBody">');
    htp.print('<a href="'||replace(replace(p_link7,'$','?'),'!','&')||'" target="content"><font  id="p_link7" color="#000000" onClick="dis_red();this.style.color = ''#FF6600''"  >&nbsp;&nbsp;'||p_label7||'</font></a></td>');
    end if;
    if ltrim(p_link8) is not null then
    htp.print('<td background="'||v_pathdad||'tab_center.gif">&nbsp;&nbsp;&nbsp;</td><td align="center"  background="'||v_pathdad||'tab.gif" class="TextBody">');
    htp.print('<a href="'||replace(replace(p_link8,'$','?'),'!','&')||'" target="content"><font  id="p_link8" color="#000000" onClick="dis_red();this.style.color = ''#FF6600''"  >&nbsp;&nbsp;'||p_label8||'</font></a></td>');
    end if;
    htp.print('  <td background="'||v_pathdad||'tab_right.gif">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>');
    htp.print('        </tr>');
    htp.print('      </table>');
    htp.print('    </td>');
    htp.print('  <tr >');
--    htp.print('    <td background="'||v_pathdad||'bg_headline.gif"></td>');
    htp.print('    <td height="2" bgcolor="#CCCCCC"></td>');

    htp.print('  </tr>');
    htp.print('<tr>');
    htp.print('    <td width="100%" align="center" valign="top">');
    htp.print('      <table align="center" width="100%"  height="450" border="0" cellpadding="0" cellspacing="0">');
    htp.print('       <tr>');
    htp.print('        <td valign="top" align="center">');
    htp.print('        <iframe  frameborder="0" name="content"  scrolling="auto" src="'||replace(replace(p_link1,'$','?'),'!','&')||'" style="width:100%;height:100%"></iframe>');
    htp.print('       </td></tr>');
    htp.print('    </table></td>');
    htp.print('</tr>');
    htp.print('</body>');
    htp.print('</html>');
end ;


FUNCTION get_title(p_lang in varchar2) RETURN varchar2 IS
BEGIN
     return get_label_name('PORTLTITLE',p_lang,0);
END;


    PROCEDURE block_click is
    BEGIN
      return;

    htp.print('<script language="javascript">');
    htp.print('PopUpURL    = "??????????"');

--  htp.print('PopUpURL    = "<% response.write  Z_RUNNUM(120)%>"');
    htp.print('isIE=document.all');
    htp.print('isNN=!document.all&&document.getElementById');
    htp.print('isN4=document.layers');
    htp.print('if (isIE||isNN)    {');
    htp.print('document.oncontextmenu=checkV');
    htp.print('} else {');
    htp.print('document.captureEvents(Event.MOUSEDOWN || Event.MOUSEUP)');
    htp.print('document.onmousedown=checkV;}');
    htp.print(' function checkV(e)');
    htp.print('{');
    htp.print('if (isN4)');
    htp.print('{');

    htp.print('if (e.which==2||e.which==3)');
    htp.print('{');
    htp.print('dPUW=alert(PopUpURL)');
    htp.print('return false');
    htp.print('}');
    htp.print('}');
    htp.print('else');
    htp.print('{');
    htp.print('dPUW=alert(PopUpURL)');
    htp.print('return false');
    htp.print('}');
    htp.print('}');
    htp.print('</script>');

    END ;

    PROCEDURE block_refresh is
    BEGIN
    --- dont  refresh ------------------------
    htp.print('<script language=javascript>');
    htp.print('document.onkeydown = function(){');
    htp.print('if(window.event && window.event.keyCode == 116)');
    htp.print('        { // Capture and remap F5');
    htp.print('    window.event.keyCode = 505;');
    htp.print('      }');
    htp.print('if(window.event && window.event.keyCode == 117)');
    htp.print('        { // Capture and remap F6');

    htp.print('    window.event.keyCode = 506;');
    htp.print('      }');
    htp.print('if(window.event && window.event.keyCode == 505)');
    htp.print('        { // New action for F5');
    htp.print('    return false;');
    htp.print('        // Must return false or the browser will refresh anyway');
    htp.print('    }');
    htp.print('if(window.event && window.event.keyCode == 506)');
    htp.print('        { // New action for F6');
    htp.print('    return false;');
    htp.print('        // Must return false or the browser will refresh anyway');
    htp.print('    }');
    htp.print('}');

    htp.print('</script>');
    -------------------------------------------
    END ;

    PROCEDURE block_backspace is
    BEGIN
    --- dont  refresh ------------------------
    htp.print('<script language=javascript>');
    htp.print('document.onkeydown = function(){');
    htp.print('if(window.event && window.event.keyCode == 8)');
    htp.print('        { // Capture and remap backspace');
    htp.print('    window.event.keyCode = 504;');
    htp.print('      }');

    htp.print('if(window.event && window.event.keyCode == 116)');
    htp.print('        { // Capture and remap F5');
    htp.print('    window.event.keyCode = 505;');
    htp.print('      }');
    htp.print('if(window.event && window.event.keyCode == 117)');
    htp.print('        { // Capture and remap F6');
    htp.print('    window.event.keyCode = 506;');
    htp.print('      }');
    htp.print('if(window.event && window.event.keyCode == 504)');
    htp.print('        { // New action for backspace');
    htp.print('    return false;');
    htp.print('        // Must return false or the browser will refresh anyway');
    htp.print('    }');

    htp.print('if(window.event && window.event.keyCode == 505)');
    htp.print('        { // New action for F5');
    htp.print('    return false;');
    htp.print('        // Must return false or the browser will refresh anyway');
    htp.print('    }');
    htp.print('if(window.event && window.event.keyCode == 506)');
    htp.print('        { // New action for F6');
    htp.print('    return false;');
    htp.print('        // Must return false or the browser will refresh anyway');
    htp.print('    }');
    htp.print('}');
    htp.print('</script>');
    -------------------------------------------

    END ;

procedure dialog_window(p_link1  in varchar2)  is
    v_pathdad  varchar2(100 char) := pdk.check_pathdad;
begin
    htp.print('<html>');
    htp.print('<head>');
    htp.print('<title>:. Employee Self Service .:</title>');
    htp.print('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">');
    htp.print('<link href="'||v_pathdad||'<%=StyleCalendar%>" rel="stylesheet" type="text/css" media=all title=win2k-1>');
    htp.print('<link rel="stylesheet" href="'||v_pathdad||'bingo.css" type="text/css">');
    htp.print('<SCRIPT LANGUAGE="JavaScript">');
    htp.print('function dis_red() {');

    htp.print('document.getElementById("p_link1").style.color = ''#000000'';');
    htp.print('}');
    htp.print('</SCRIPT>');
    htp.print('</head>');
    htp.print('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">');
    htp.print('   <table cellpadding="0" cellspacing="0" border="0" width="100%" height="50">');
    htp.print('    <tr height="50">');
    htp.print('      <td background="'||v_pathdad||'bg_fexi.gif">');
    htp.print('        <table width="100%" height="50" border="0" cellpadding="0" cellspacing="0">');
    htp.print('          <tr>');
    htp.print('            <td width="18%" align="center">');
    htp.print('              <table width="74" border="0" cellspacing="0" cellpadding="0">');
    htp.print('                <tr>');

    htp.print('                  <td ><object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0" width="74" height="50">');
    htp.print('                     <param name="movie" value="'||v_pathdad||'s_logohrms.swf">');
    htp.print('                     <param name="quality" value="high">');
    htp.print('                     <embed src="'||v_pathdad||'s_logohrms.swf" width="74" height="50" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" ></embed></object></td>');
    htp.print('                </tr>');
    htp.print('              </table>');
    htp.print('            </td>');
    htp.print('            <td width="73%"><object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0" width="203" height="50">');
    htp.print('            <param name="movie" value="'||v_pathdad||'ess.swf">');
    htp.print('            <param name="quality" value="high">');
    htp.print('            <param name="wmode" value="transparent">');
    htp.print('            <param name="menu" value="false">');
    htp.print('            <embed src="'||v_pathdad||'ess.swf" width="203" height="50" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" wmode="transparent" menu="false"></embed></object></td>');

    htp.print('            <td width="9%">');
    htp.print('              <table width="63" border="0" cellspacing="0" cellpadding="0">');
    htp.print('                <tr>');
    htp.print('                  <td align="center"><img src="'||v_pathdad||'s_bottom.gif" width="262" height="50"></td>');
    htp.print('                </tr>');
    htp.print('              </table>');
    htp.print('            </td>');
    htp.print('          </tr>');
    htp.print('        </table>');
    htp.print('      </td>');
    htp.print('    </tr>');

    htp.print('  <tr >');

    htp.print('    <td height="2" bgcolor="#CCCCCC"></td>');
    htp.print('  </tr>');
    htp.print('<tr>');
    htp.print('    <td width="100%" align="center" valign="top">');
    htp.print('      <table align="center" width="100%"  height="450" border="0" cellpadding="0" cellspacing="0">');
    htp.print('       <tr>');
    htp.print('        <td valign="top" align="center">');
    htp.print('        <iframe  frameborder="0" name="content"  scrolling="auto" src="'||replace(replace(p_link1,'$','?'),'!','&')||'" style="width:100%;height:100%"></iframe>');
    htp.print('       </td></tr>');
    htp.print('    </table></td>');
    htp.print('</tr>');
    htp.print('</body>');
    htp.print('</html>');

end ;

PROCEDURE keynextitem is

    begin

    htp.print('<script type="text/javascript">
        function keynextitem(objId){
            if (event.keyCode == 13){
                var obj=document.getElementById(objId);
                if (obj){

                    obj.focus();

                }
            }
        }
    </script> ');
    /*  ---------------- how to use function ---------------
    pdk.keynextitem;

htp.print('<input type="text" id="txtFirstName" value="" onkeydown="keynextitem(''txtLastName'');" />');
htp.print('<input type="text" id="txtLastName" value="" onkeydown="keynextitem(''cmdOk'');" />');
htp.print('<input type="button" id="cmdOk" value="" />');

    */
    END ;


   PROCEDURE getempname(p_coduser in varchar2,p_lang in varchar2) is

    begin

    htp.print('<script type="text/javascript">
        function getempname(objId,objval,objgo){
            if (event.keyCode == 13){
                var obj=document.getElementById(objId);
                if (obj){
                    var obv = document.getElementById(objval);
                    var  popW = 400;
                    var  popH = 110;

                    var v_lang    = "'||p_lang||'";
                    var v_coduser = "'||p_coduser||'";
                    var winleft = (screen.width - popW) / 2;
                    var winUp   = (screen.height - popH) / 3;

                    var  itemtran  = objId ;
                    var  itemwhere = obv.value;
                    var  itemgo    = objgo;
                    var  v_link = "PDK.gettemployname?itemtran=" +itemtran+ "&itemwhere=" + itemwhere + "&itemgo=" + itemgo + "&p_coduser=" + v_coduser + "&p_lang=" + v_lang ;
                    var winsize = "dialogWidth:"+popW+"px;dialogHeight:"+popH+"px;help:no;status:yes;";
                    winProp = ''width=''+popW+'',height=''+popH+'',left=''+winleft+'',top=''+winUp+'',scrollbars=''+scroll+'',resizable=0''
                    Win = window.open(v_link, '''', winProp)   ');


--                    htp.print('obj.focus(); ');
                htp.print('}
            }
        }
    </script> ');
    /*  ---------------- how to use function ---------------
    pdk.keynextitem;

htp.print('<input type="text" id="txtFirstName" value="" onkeydown="keynextitem(''txtLastName'');" />');
htp.print('<input type="text" id="txtLastName" value="" onkeydown="keynextitem(''cmdOk'');" />');
htp.print('<input type="button" id="cmdOk" value="" />');

    */

    END ;



PROCEDURE gettemployname(itemtran  IN VARCHAR2,
                itemwhere IN VARCHAR2,
                itemgo    in varchar2,
                p_coduser  IN VARCHAR2,
                p_lang  IN VARCHAR2 ) IS
     v_pathdad     varchar2(100 char) := check_pathdad;
     v_desc        varchar2(100 char);
BEGIN
    begin

        v_desc  := get_temploy_name(''||itemwhere||'',p_lang);
    end;

    htp.print('<HTML>');
    htp.print('<HEAD>');
    htp.print('<TITLE>______________:::. www.tjs.co.th .:::______________</TITLE>');
    htp.print('<SCRIPT LANGUAGE="JavaScript">');

    htp.print('function auto_page() {');
    htp.print('setTimeout("check_index()",300);');
    htp.print('}');

    htp.print('function check_index() {');

    htp.print('window.opener.form1.'||itemtran||'.value    = '''||v_desc||''';');
    htp.print('window.opener.form1.'||itemgo||'.focus();');
    htp.print('window.close();');
    htp.print('}');

    htp.print('</script>');
    htp.print('</head>');

--    htp.print('<body leftmargin="0" onLoad="setTimeout("auto_page()",2000);" topmargin="0" onUnload="return_codprc()">');
    htp.print('<body leftmargin="0" onLoad="auto_page()" topmargin="0" onUnload="check_index()">');
    htp.print('<form name="form1"><table width="400" height="110" align="center" border="1" cellpadding="0" cellspacing="0" bgcolor="#DFE8EE" bordercolor="#8FABC2">');
    htp.print('     <tr>');
    htp.print('       <td  align="center" valign="middle" class="TextBodyHead"> ');

    htp.print('<br><table width="100%" align="center"  border="0" cellspacing="2" cellpadding="2">');
    htp.print('    <tr> ');
    htp.print('    <td width="20%" align="right" ><img src="'||v_pathdad||'warning.gif" width="47" height="47" align="absmiddle" border="0" ></td>');
    htp.print('      <td class="TextBody" width="80%"><font color="#000000"><b>'||'Now loading ... Please  wait !'||'</b></font></td>');
    htp.print('    </tr>');
    htp.print('    </table>');
    htp.print('<table width="100%" align="center"  border="0" cellspacing="2" cellpadding="2">');
    htp.print('    <tr align="center" valign="baseline"> ');
    htp.print('      <td colspan="2"> ');
--    htp.print('<button onClick="check_index()" class="Buttonx">Close</button>');
    htp.print('</td></tr>');
    htp.print('  </table></form>');


    htp.print('</body>');

END; --

procedure window_close (p_lang in varchar2) is

begin
    htp.print('<script language="JavaScript">');
    htp.print('  var alterffourflag =0;');
    htp.print('  var lastkey        =0;');
    htp.print('  var refreshflag    =0;');
    htp.print('  document.onkeydown = function ( event ) {');
    htp.print('  event = event || window.event;');

    htp.print('  return window_onkeydown();');
    htp.print('}');
    htp.print('</script>');

    htp.print('  <script for=window event=onunload>');
    htp.print('  ie7=navigator.userAgent.toLowerCase().indexOf("msie 7")!=-1;');
    htp.print('    if(ie7==1){');
    htp.print('       if(window.document.referrer.toString()==" "){');
    htp.print('         return; ');
    htp.print('        }');
    htp.print('         var offset =0.0;');
    htp.print('         var width  =0.0;');
    htp.print('           if( document.documentElement && ( document.documentElement.clientWidth )) {');

    htp.print('             //IE 6+ in ''''standards compliant mode''''');
    htp.print('             width = document.documentElement.clientWidth;');
    htp.print('           }');
    htp.print('            else if( document.body && ( document.body.offsetWidth)) {');
    htp.print('            width=document.body.offsetWidth;');
    htp.print('           }');
    htp.print('            offset = 18500/screen.width;');
    htp.print('            var diff =width-offset;');
    htp.print('            if (refreshflag!=1 && width!=0 && window.event.clientY < 0 && (window.event.clientX > (width - offset))||alterffourflag==1) {');
    htp.print('              if(window.opener == null || window.opener != null) {');
    htp.print('                if (window.XMLHttpRequest) {');
    ------------------------------------
    htp.print('                 alert("Do you Want To Close"); ');

    ------------------------------------
    htp.print('                }');
    htp.print('             else {');
    htp.print('                   if (window.ActiveXObject) {');
    htp.print('                   }');
    htp.print('             }');
    htp.print('             }');
    htp.print('          }');
    htp.print('        refreshflag=0;');
    htp.print('        }');
    htp.print('   else {// IE6');
    htp.print('        if (self.screenTop > 10000 && event.clientY < 0 && event.clientX < 0) {');
    htp.print('          if(window.opener == null || window.opener != null) {');

    htp.print('             if (window.XMLHttpRequest) {');
    htp.print('             }');
    htp.print('             else {');
    htp.print('               if (window.ActiveXObject) {');
    ------------------------------------
    htp.print('                 alert("Do you Want To Close"); ');
    ------------------------------------
    htp.print('             }');
    htp.print('           }');
    htp.print('         }');
    htp.print('   }');
    htp.print('   }');
    htp.print('  </script>');

end;

procedure include_js is
begin
  -- JJ 20/03/2015 Main JavaScript
    htp.print('<script language="JavaScript">');
    htp.print('
      // fix for deprecated method in Chrome 37
      if (!window.showModalDialog) {
         window.dialogArguments = window.opener;
         window.showModalDialog = function (arg1, arg2, arg3) {

            var w;

            var h;
            var resizable = "no";
            var scroll = "no";
            var status = "no";

            // get the modal specs
            var mdattrs = arg3.split(";");
            for (i = 0; i < mdattrs.length; i++) {
               var mdattr = mdattrs[i].split(":");

               var n = mdattr[0];
               var v = mdattr[1];
               if (n) { n = n.trim().toLowerCase(); }

               if (v) { v = v.trim().toLowerCase(); }

               if (n == "dialogheight") {
                  h = v.replace("px", "");
               } else if (n == "dialogwidth") {
                  w = v.replace("px", "");
               } else if (n == "resizable") {
                  resizable = v;
               } else if (n == "scroll") {
                  scroll = v;
               } else if (n == "status") {
                  status = v;
               }

            }

            var left = window.screenX + (window.outerWidth / 2) - (w / 2);
            var top = window.screenY + (window.outerHeight / 2) - (h / 2);
            var targetWin = window.open(arg1, arg1, "toolbar=no, location=no, directories=no, status=" + status + ", menubar=no, scrollbars=" + scroll + ", resizable=" + resizable + ", copyhistory=no, width=" + w + ", height=" + h + ", top=" + top + ", left=" + left);
            targetWin.focus();

            // dialogArguments for Chrome
            targetWin.dialogArguments = window;
         };
      }

    ');

    htp.print('  </script>');
end;

procedure include_css is
begin
  htp.print('<style>');
  htp.print('   .text-upper{text-transform: uppercase;}');
  htp.print('</style>');
end;

END;-- Pgk Body

/

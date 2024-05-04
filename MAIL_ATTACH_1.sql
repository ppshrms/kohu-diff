--------------------------------------------------------
--  DDL for Package Body MAIL_ATTACH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MAIL_ATTACH" IS

  -- Return the next email address in the list of email addresses, separated
  -- by either a "," or a ";".  The format of mailbox may be in one of these:
  --   someone@some-domain
  --   "Someone at some domain" <someone@some-domain>
  --   Someone at some domain <someone@some-domain>


  FUNCTION get_address(addr_list IN OUT VARCHAR2) RETURN VARCHAR2 IS

    addr VARCHAR2(256);
    i    PLS_INTEGER;
    j    PLS_INTEGER;

    FUNCTION lookup_unquoted_char(str  IN VARCHAR2,
                  chrs IN VARCHAR2) RETURN PLS_INTEGER AS
      c            VARCHAR2(5);
      i            PLS_INTEGER;

      len          PLS_INTEGER;
      inside_quote BOOLEAN;
    BEGIN
       inside_quote := FALSE;
       i := 1;
       len := LENGTH(str);
       WHILE (i <= len) LOOP

     c := SUBSTR(str, i, 1);

     IF (inside_quote) THEN
       IF (c = '"') THEN
         inside_quote := FALSE;
       ELSIF (c = '\') THEN
         i := i + 1; -- Skip the quote character
       END IF;
       GOTO next_char;
     END IF;

     IF (c = '"') THEN
       inside_quote := TRUE;
       GOTO next_char;
     END IF;

     IF (INSTR(chrs, c) >= 1) THEN
        RETURN i;
     END IF;

     <<next_char>>
     i := i + 1;

       END LOOP;

       RETURN 0;

    END;

  BEGIN

    addr_list := LTRIM(addr_list);
    i := lookup_unquoted_char(addr_list, ',;');
    IF (i >= 1) THEN
      addr      := SUBSTR(addr_list, 1, i - 1);
      addr_list := SUBSTR(addr_list, i + 1);
    ELSE
      addr := addr_list;
      addr_list := '';
    END IF;

    i := lookup_unquoted_char(addr, '<');
    IF (i >= 1) THEN
      addr := SUBSTR(addr, i + 1);
      i := INSTR(addr, '>');
      IF (i >= 1) THEN
    addr := SUBSTR(addr, 1, i - 1);
      END IF;
    END IF;

    RETURN addr;
  END;

  -- Write a MIME header
  PROCEDURE write_mime_header(conn  IN OUT NOCOPY utl_smtp.connection,
                  name  IN VARCHAR2,
                  value IN VARCHAR2) IS
  BEGIN
--Chai modify
    --utl_smtp.write_data(conn, name || ': ' || value || utl_tcp.CRLF);

    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(name || ': ' || value||''|| utl_tcp.CRLF));
  END;

  -- Mark a message-part boundary.  Set <last> to TRUE for the last boundary.
  PROCEDURE write_boundary(conn  IN OUT NOCOPY utl_smtp.connection,
               last  IN            BOOLEAN DEFAULT FALSE) AS
  BEGIN
    IF (last) THEN
      utl_smtp.write_data(conn, LAST_BOUNDARY);
    ELSE
      utl_smtp.write_data(conn, FIRST_BOUNDARY);
    END IF;
  END;

  ------------------------------------------------------------------------
  PROCEDURE mail(sender     IN VARCHAR2,
                 recipients IN VARCHAR2,
                 carboncopy IN VARCHAR2,
                 subject    IN VARCHAR2,
                 message    IN VARCHAR2) IS
    conn utl_smtp.connection;
  BEGIN
    conn := begin_mail(sender, recipients,carboncopy, subject,message);
    write_text(conn, message);
    write_mb_text(conn, message);   -- use thai language
    end_mail(conn);
  END;

  ------------------------------------------------------------------------
  FUNCTION begin_mail(
              sender     IN VARCHAR2,
              recipients IN VARCHAR2,
              carboncopy IN VARCHAR2,
              subject    IN VARCHAR2,
              data       IN VARCHAR2,
              mime_type  IN VARCHAR2,
              priority   IN PLS_INTEGER DEFAULT NULL)
              RETURN utl_smtp.connection IS
    conn utl_smtp.connection;
  begin
     mail_attach.smtp_host   := get_tsetup_value('MAILSERV');
     mail_attach.smtp_port   := get_tsetup_value('MAILPORT');
     mail_attach.smtp_domain := get_tsetup_value('MAILSERV');
     conn := begin_session;
     begin_mail_in_session(conn, sender, recipients, carboncopy,subject,data ,mime_type,priority);
    RETURN conn;
  END;

  ------------------------------------------------------------------------
  PROCEDURE write_text(conn    IN OUT NOCOPY utl_smtp.connection,
               message IN VARCHAR2) IS
  BEGIN
      utl_smtp.write_data(conn, message);
  END;

  ------------------------------------------------------------------------
  PROCEDURE write_mb_text(conn    IN OUT NOCOPY utl_smtp.connection,
              message IN            VARCHAR2) IS
  BEGIN
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(message));
  END;

  ------------------------------------------------------------------------
  PROCEDURE write_raw(conn    IN OUT NOCOPY utl_smtp.connection,
              message IN RAW) IS
  BEGIN
    utl_smtp.write_raw_data(conn, message);
  END;

  ------------------------------------------------------------------------
  PROCEDURE attach_text(conn         IN OUT NOCOPY utl_smtp.connection,
            data         IN VARCHAR2,
            mime_type    IN VARCHAR2,
            inline       IN BOOLEAN  DEFAULT TRUE,
            filename     IN VARCHAR2 DEFAULT NULL,
            last         IN BOOLEAN  DEFAULT FALSE) IS
  BEGIN
    begin_attachment(conn, mime_type, inline, filename);
  --  write_text(conn, data);
--     write_raw(conn, data);
    write_mb_text(conn, data);
    end_attachment(conn, last);
  END;

  ------------------------------------------------------------------------
  PROCEDURE attach_base64(conn         IN OUT NOCOPY utl_smtp.connection,
              data         IN RAW,
              mime_type    IN VARCHAR2 DEFAULT 'application/octet',
              inline       IN BOOLEAN  DEFAULT TRUE,
              filename     IN VARCHAR2 DEFAULT NULL,
              last         IN BOOLEAN  DEFAULT FALSE) IS
    i   PLS_INTEGER;
    len PLS_INTEGER;
  BEGIN

    begin_attachment(conn, mime_type, inline, filename, 'base64');

    -- Split the Base64-encoded attachment into multiple lines
    i   := 1;
    len := utl_raw.LENGTH(data);

    WHILE (i < len) LOOP
       IF (i + MAX_BASE64_LINE_WIDTH < len) THEN
     utl_smtp.write_raw_data(conn,
        utl_encode.base64_encode(utl_raw.SUBSTR(data, i,
        MAX_BASE64_LINE_WIDTH)));
       ELSE
     utl_smtp.write_raw_data(conn,
       utl_encode.base64_encode(utl_raw.SUBSTR(data, i)));
       END IF;
       utl_smtp.write_data(conn, utl_tcp.CRLF);
       i := i + MAX_BASE64_LINE_WIDTH;
    END LOOP;

    end_attachment(conn, last);

  END;

  ------------------------------------------------------------------------
  PROCEDURE begin_attachment(conn         IN OUT NOCOPY utl_smtp.connection,
                 mime_type    IN VARCHAR2 DEFAULT v_mime_type,
                 inline       IN BOOLEAN  DEFAULT TRUE,
                 filename     IN VARCHAR2 DEFAULT NULL,
                 transfer_enc IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    write_boundary(conn);

    IF (filename IS NOT NULL) THEN
       IF (inline) THEN
      write_mime_header(conn, 'Content-Disposition',
        'inline; filename="'||filename||'"');
       ELSE
      write_mime_header(conn, 'Content-Disposition',
        'attachment; filename="'||filename||'"');
       END IF;
    --else
      --write_mime_header(conn, 'Content-Type', mime_type);
    END IF;

    IF (transfer_enc IS NOT NULL) THEN
      write_mime_header(conn, 'Content-Transfer-Encoding', transfer_enc);
    END IF;

    utl_smtp.write_data(conn, utl_tcp.CRLF);
   -- utl_smtp.write_raw_data(conn, utl_tcp.CRLF);
  END;

  ------------------------------------------------------------------------
  PROCEDURE end_attachment(conn IN OUT NOCOPY utl_smtp.connection,
               last IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    utl_smtp.write_data(conn, utl_tcp.CRLF);
    --utl_smtp.write_raw_data(conn, utl_tcp.CRLF);
    IF (last) THEN
      write_boundary(conn, last);
    END IF;
  END;

  ------------------------------------------------------------------------
  PROCEDURE end_mail(conn IN OUT NOCOPY utl_smtp.connection) IS
  BEGIN
    end_mail_in_session(conn);
    end_session(conn);
  END;

  ------------------------------------------------------------------------
  FUNCTION begin_session RETURN utl_smtp.connection IS
    conn utl_smtp.connection;
    v_mail_auth   varchar2(100);
    v_pwd_auth    varchar2(100);
  BEGIN
    -- open SMTP connection
    v_mail_auth := get_tsetup_value('MAIL_AUTH');
    v_pwd_auth  := get_tsetup_value('PWD_AUTH');
    conn := utl_smtp.open_connection(smtp_host, smtp_port);
    if v_mail_auth is not null then
       utl_smtp.command( conn, 'AUTH LOGIN');
       utl_smtp.command( conn, utl_raw.cast_to_varchar2( utl_encode.base64_encode( utl_raw.cast_to_raw(v_mail_auth ))) );
       utl_smtp.command( conn, utl_raw.cast_to_varchar2( utl_encode.base64_encode( utl_raw.cast_to_raw(v_pwd_auth))) );
    end if;
    utl_smtp.helo(conn, smtp_domain);
    RETURN conn;
  END;

  ------------------------------------------------------------------------
  PROCEDURE begin_mail_in_session(conn       IN OUT NOCOPY utl_smtp.connection,
                  sender     IN VARCHAR2,
                  recipients IN VARCHAR2,
                  carboncopy IN VARCHAR2,
                  subject    IN VARCHAR2,
                  data       IN VARCHAR2,
                  mime_type  IN VARCHAR2,
                  priority   IN PLS_INTEGER DEFAULT NULL) IS
    my_recipients varchar2(32767) := recipients;
    my_sender     varchar2(32767) := sender;
    crlf          varchar2( 2 )   := chr( 13 ) || chr( 10 );
    p_msg         varchar2(32767) ;
    v_data        varchar2(32767) ;
    v_convert     VARCHAR2(20) := NVL(get_tsetup_value('CODEMAIL_ATT'),'AL32UTF8');
  begin
    utl_smtp.mail(conn,my_sender);
    utl_smtp.rcpt(conn,my_recipients);
    utl_smtp.open_data(conn);
    p_msg := 'From: ' ||sender|| crlf ||
             'To: '||recipients||crlf||
             'Cc: '||carboncopy||crlf||
             'Subject: '||subject||crlf||
             'Content-Type: '||mime_type||crlf||crlf;
    v_data := data;
    if v_convert <> 'AL32UTF8' then
       p_msg := convert(p_msg,v_convert);
       v_data  := convert(v_data,v_convert);
    end if;
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(p_msg||crlf));
    UTL_SMTP.write_data(conn, '--' ||BOUNDARY|| crlf);
    UTL_SMTP.write_data(conn, 'Content-Type: text/html; '||NVL(get_tsetup_value('CHARSET_ATT'),'charset=UTF-8')||crlf||crlf);
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(v_data||crlf||crlf));
  END;

  ------------------------------------------------------------------------
  PROCEDURE end_mail_in_session(conn IN OUT NOCOPY utl_smtp.connection) IS
  BEGIN
    utl_smtp.close_data(conn);
  END;

  ------------------------------------------------------------------------
  PROCEDURE end_session(conn IN OUT NOCOPY utl_smtp.connection) IS
  BEGIN
    utl_smtp.quit(conn);
  END;

END;

/

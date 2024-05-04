--------------------------------------------------------
--  DDL for Package MAIL_ATTACH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "MAIL_ATTACH" IS

  ----------------------- Customizable Section -----------------------

  smtp_host   VARCHAR2(256);
  smtp_port   PLS_INTEGER ;
  smtp_domain VARCHAR2(256);
  v_charset   VARCHAR2(10);
  v_mime_type VARCHAR2(50) := 'text/html;'||NVL(get_tsetup_value('CHARSET_ATT'),'charset=UTF-8');


  -- Customize the signature that will appear in the email's MIME header.
  -- Useful for versioning.
   MAILER_ID   CONSTANT VARCHAR2(256) := 'Mailer by People Plus Software';

  --------------------- End Customizable Section ---------------------

  -- A unique string that demarcates boundaries of parts in a multi-part email
  -- The string should not appear inside the body of any part of the email.
  -- Customize this if needed or generate this randomly dynamically.
  BOUNDARY        CONSTANT VARCHAR2(256) := '-----7D81B75CCC90D2974F7A1CBD';

  FIRST_BOUNDARY  CONSTANT VARCHAR2(256) := '--' || BOUNDARY || utl_tcp.CRLF;
  LAST_BOUNDARY   CONSTANT VARCHAR2(256) := '--' || BOUNDARY || '--' ||utl_tcp.CRLF;

  -- A MIME type that denotes multi-part email (MIME) messages.
  MULTIPART_MIME_TYPE   CONSTANT VARCHAR2(256) := 'multipart/mixed; boundary="'||BOUNDARY || '"';
  MAX_BASE64_LINE_WIDTH CONSTANT PLS_INTEGER   := 76 / 4 * 3;

  -- A simple email API for sending email in plain text in a single call.
  -- The format of an email address is one of these:
  --   someone@some-domain
  --   "Someone at some domain" <someone@some-domain>
  --   Someone at some domain <someone@some-domain>
  -- The recipients is a list of email addresses  separated by
  -- either a "," or a ";"
  PROCEDURE mail(sender     IN VARCHAR2,
         recipients IN VARCHAR2,
         carboncopy IN VARCHAR2,
         subject    IN VARCHAR2,
         message    IN VARCHAR2);

  -- Extended email API to send email in HTML or plain text with no size limit.
  -- First, begin the email by begin_mail(). Then, call write_text() repeatedly
  -- to send email in ASCII piece-by-piece. Or, call write_mb_text() to send
  -- email in non-ASCII or multi-byte character set. End the email with
  -- end_mail().
  PROCEDURE write_text(conn    IN OUT NOCOPY utl_smtp.connection,
               message IN VARCHAR2);

  -- Write email body in non-ASCII (including multi-byte). The email body
  -- will be sent in the database character set.
  PROCEDURE write_mb_text(conn    IN OUT NOCOPY utl_smtp.connection,
              message IN            VARCHAR2);

  -- Write email body in binary
  PROCEDURE write_raw(conn    IN OUT NOCOPY utl_smtp.connection,
              message IN RAW);

  -- APIs to send email with attachments. Attachments are sent by sending
  -- emails in "multipart/mixed" MIME format. Specify that MIME format when
  -- beginning an email with begin_mail().

  -- Send a single text attachment.
  PROCEDURE attach_base64(conn         IN OUT NOCOPY utl_smtp.connection,
              data         IN RAW,
              mime_type    IN VARCHAR2 DEFAULT 'application/octet',
              inline       IN BOOLEAN  DEFAULT TRUE,
              filename     IN VARCHAR2 DEFAULT NULL,
              last         IN BOOLEAN  DEFAULT FALSE);

  -- Send an attachment with no size limit. First, begin the attachment
  -- with begin_attachment(). Then, call write_text repeatedly to send
  -- the attachment piece-by-piece. If the attachment is text-based but
  -- in non-ASCII or multi-byte character set, use write_mb_text() instead.
  -- To send binary attachment, the binary content should first be
  -- encoded in Base-64 encoding format using the demo package for 8i,
  -- or the native one in 9i. End the attachment with end_attachment.
  PROCEDURE end_attachment(conn IN OUT NOCOPY utl_smtp.connection,
               last IN BOOLEAN DEFAULT FALSE);

  -- End the email.
  PROCEDURE end_mail(conn IN OUT NOCOPY utl_smtp.connection);

  -- Extended email API to send multiple emails in a session for better
  -- performance. First, begin an email session with begin_session.
  -- Then, begin each email with a session by calling begin_mail_in_session
  -- instead of begin_mail. End the email with end_mail_in_session instead
  -- of end_mail. End the email session by end_session.
  FUNCTION begin_session RETURN utl_smtp.connection;

  -- Begin an email in a session.
  PROCEDURE end_mail_in_session(conn IN OUT NOCOPY utl_smtp.connection);

  -- End an email session.
  PROCEDURE end_session(conn IN OUT NOCOPY utl_smtp.connection);

  FUNCTION get_address(addr_list IN OUT VARCHAR2) RETURN VARCHAR2;
  PROCEDURE write_boundary(conn  IN OUT NOCOPY utl_smtp.connection,
               last  IN            BOOLEAN DEFAULT FALSE);
  PROCEDURE write_mime_header(conn  IN OUT NOCOPY utl_smtp.connection,
                  name  IN VARCHAR2,
                  value IN VARCHAR2);
  procedure BEGIN_ATTACHMENT(CONN         in OUT NOCOPY UTL_SMTP.CONNECTION,
                 mime_type    IN VARCHAR2 DEFAULT v_mime_type,
                 inline       IN BOOLEAN  DEFAULT TRUE,
                 filename     IN VARCHAR2 DEFAULT NULL,
                 transfer_enc IN VARCHAR2 DEFAULT NULL);
  PROCEDURE attach_text(conn         IN OUT NOCOPY utl_smtp.connection,
            data         IN VARCHAR2,
            mime_type    IN VARCHAR2 DEFAULT v_mime_type,
            inline       IN BOOLEAN  DEFAULT TRUE,
            filename     IN VARCHAR2 DEFAULT NULL,
                last         IN BOOLEAN  DEFAULT FALSE);
  PROCEDURE begin_mail_in_session(conn       IN OUT NOCOPY utl_smtp.connection,
                  sender     IN VARCHAR2,
                  recipients IN VARCHAR2,
                  carboncopy IN VARCHAR2,
                  subject    IN VARCHAR2,
                  data       IN VARCHAR2,
                  mime_type  IN VARCHAR2  DEFAULT v_mime_type,
                  priority   IN PLS_INTEGER DEFAULT NULL);
  FUNCTION begin_mail(
              sender     IN VARCHAR2,
              recipients IN VARCHAR2,
              carboncopy IN VARCHAR2,
              subject    IN VARCHAR2,
              data       IN VARCHAR2,
              mime_type  IN VARCHAR2    DEFAULT v_mime_type,
              priority   IN PLS_INTEGER DEFAULT NULL)
              RETURN utl_smtp.connection;
END;

/

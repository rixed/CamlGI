(* File: CGISendmail.mli

   Copyright (C) 2004

     Christophe Troestler
     email: Christophe.Troestler@umh.ac.be
     WWW: http://www.umh.ac.be/math/an/software/

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public License
   version 2.1 as published by the Free Software Foundation, with the
   special exception on linking described in file LICENSE.

   This library is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
   LICENSE for more details.
*)
exception Failure of string
  (** This exception may be thrown by any of the functions in this
module, to indicate some problem running sendmail.  *)

val sendmail : string ref
  (** This contains the path to sendmail (or the binary which acts
like sendmail, as in the case of exim).  Normally this is set
to the correct value for your OS, eg. ["/usr/sbin/sendmail"].
  *)
val sendmail_args : string ref
  (** This contains the arguments passed to sendmail, normally ["-t
-i"].  You could add the ["-f"] option to specify the sender
email address, provided that the current user is one of
sendmail's trusted users.  *)

val send : unit -> out_channel
  (** Begin sending an email.  This returns a channel on which you
should write the mail headers, followed by a blank line,
followed by the message body.  After writing the mail you
must call {!CamlGI.Sendmail.close}.

[send] does not perform any sort of processing or escaping on
the message.  *)

val close : out_channel -> unit
  (** Close the output channel.  You must call this on the channel
returned from {!CamlGI.Sendmail.send}.  *)

val send_mail : ?subject:string ->
  ?to_addr:string list -> ?cc:string list -> ?bcc:string list ->
  ?from:string -> ?content_type:string ->
  ?headers:(string * string) list ->
  string -> unit
  (** This is a less flexible, but simpler interface to sending
mail.  You specify, optionally, Subject line, To, Cc, Bcc,
From and Content-Type headers, and a body, and a mail is
generated.

[send_mail] will correctly escape headers, provided they
are in strict 7 bit US-ASCII.  Its behaviour on non-7 bit
sequences is currently undefined (and probably wrong).
[send_mail] will not process or escape any part of the body.
  *)

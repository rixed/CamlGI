(* File: CamlGI.mli

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
(** (F)CGI high level functions *)
module Cookie = CgiCookie

module Request :
sig
  type t
    (** Type representing the information contained in one request
  of the web server. *)

  val gateway : t -> CgiTypes.gateway
    (** The type and version of the CGI used. *)
  val role : t -> CgiTypes.role
    (** The role of the script. *)

  val path_info : t -> string
    (** Returns the PATH_INFO, that is the portion of the URI
  following the script name but preceding the query data.  "/"
  represent a single void path segment.  The CGI specifications
  recommend to return "404 Not Found" if path_info <> "" but is
  not used. *)
  val protocol : t -> string
    (** The protocol of the request, in uppercase.  E.g. "HTTP/1.1". *)
  val remote_addr : t -> string
    (** The IP adress of the client making the request.  Note it can
  be the one of a proxy in the middle. *)
  val server_name : t -> string
    (** Name of the server, derived from the host part of the script URI. *)
  val server_port : t -> int
    (** The port on which the request was received. *)
  val server_software : t -> string
    (** The name and version of the web server software answering the
  request. *)

  val accept : t -> string
    (** Returns the list of accepted MIME types by the client. *)
  val accept_charset : t -> string
    (** Return a list of charset supported by the client. *)
  val accept_encoding : t -> string
    (** List of encodings supported by the client. *)
  val auth : t -> string
    (** The HTTP authentication scheme.  E.g. "Basic".  See section 11
  of the HTTP/1.1 specification for more details. *)
  val user : t -> string
    (** The user-ID supplied when [auth r = "Basic"]. *)
  val user_agent : t -> string
    (** The identification of the client browser. *)

  val metavar : t -> string -> string
    (** [metavar r name] returns the value of the CGI metavariable
  [name] for the request [r].  (Remember that CGI does not
  distinguish between nonexisting arguments and arguments with
  value [""].) *)

  val print_string : t -> string -> unit
  val prerr_string : t -> string -> unit
end


(** {3 Setting up the application server} *)

val establish_server : ?max_conns:int -> ?max_reqs:int ->
  ?sockaddr:Unix.sockaddr -> ?post_max:int ->
  (CgiTypes.connection -> unit) -> unit
  (** [establish_server ?max_conns ?max_reqs ?sockaddr ?post_max f]
starts a server listening on the socket appropriate for CGI or
FCGI and, for each accepted connection [conn], executes [f
conn].  The exceptions possibly raised by [f] are not caught
by [establish_server].  It is no problem that [f] starts a new
thread to handle the connection (and thus returns immediately).

@param max_conns is the maximum of connections the web server
can make to this script.  By default, each connection is
processed sequentially, so the default value for [max_conns]
is [1].  If you start processes or threads to handle
connections, it is your responsibility not to accept more than
[max_conns] connections.  The value of [max_conns] only serves
to inform the web server about the capabilities of the FCGI
script.

@param max_reqs is the maximum of requests a web server can
multiplex through a given connection.  Again, if you start
processes or threads to handle requests, it is your
responsibility to limit the number of them.  [max_reqs] is
only used to inform the web server about how many requests it
can multiplex on a given connection.  Beware that if you set
[max_reqs] to [1] but have threads handling different requests
of a given connection, the outputs may mix-up (thus be
incorrect).

@param sockaddr the unix or the TCP/IP socket that the script
will use to communicate with the web server.  Setting this
implies that the script uses the FCGI protocol.  By default,
on uses what is appropriate for the CGI OR FCGI protocol.  For
example, if your script is listening on port 8888 on a
possibly remote machine, you can use
[Unix.ADDR_INET(Unix.inet_addr_any, 8888)].

@param post_max set the maximum size for POSTed requests in
bytes.  This is a security feature to prevent clients from
overrunning the server with data.  The default is
[Sys.max_string_length], meaning no limit (besides OCaml
ones).

For FastCGI, the environment variable FCGI_WEB_SERVER_ADDRS
may be used to specify a coma separated list of IP addresses
from which the web server can connect.  If not set, any
address is accepted.  *)

val handle_requests : ?fork:((Request.t -> unit) -> Request.t -> unit) ->
  (Request.t -> unit) -> CgiTypes.connection -> unit
  (** [handle_requests ?fork f conn] listen on the connection [conn]
for requests.  For each completed request [req], it executes
[fork f req].

@param fork the function that starts a new process or thread.
The default is to execute [f] and only after continue to
listen for more requests.

Exceptions thrown by [f] are caught (so the possible thread
executing [f] will not be terminated by these).  The exception
[Exit] is caught and ignored (this is considered a valid way
of ending a script).  {!CgiTypes.HttpError} exceptions are
turned into appropriate error codes.  All other exceptions
provoke a internal server error and are logged in the server
error log.

Note that the exceptions raised by [fork] are NOT caught. *)

val register_script : ?sockaddr:Unix.sockaddr -> (Request.t -> unit) -> unit
  (** Scripts must call [register_script f] once to register their
main function [f].  This should be called last (nothing that
follows will be executed).  The data is buffered and may not
be fully written before [f] ends.

This is actually a convenience function that sets up a server (with
[establish_server]) and processes (through [handle_requests])
all connections and requests sequentially -- i.e. no
fork/thread. *)


(** {3 Cgi} *)

(** Type of acceptable template objects. *)
class type template =
object
  method output : (string -> unit) -> unit
    (** [#output print] must use the [print] function to output the
  template (with the necessary substitutions done,...). *)
end

(** [new cgi r] creates a cgi object for the request [r].  Note that
    you are advised not to create more than one cgi per request
    unless you know what you are doing.  *)
class cgi : Request.t ->
object
  method header : ?content_type:string -> ?cookie:Cookie.cookie ->
    ?cookies:Cookie.cookie list -> ?cookie_cache:bool -> ?status:int ->
    ?err_msg:string -> unit -> unit
    (** Emit the header. The default content type is "text/html". *)

  method template : 'a. ?content_type:string -> ?cookie:Cookie.cookie ->
    ?cookies:Cookie.cookie list -> ?cookie_cache:bool ->
    (#template as 'a) -> unit
    (** Emit the header (unless #header was issued before) followed by
  the given template.  @raise Failure if the output is not
  successful. *)

  method exit : unit -> 'a
  (** Exit the current cgi script.  (You need not to call this at
the end of your code, just if you want to exit earlier.)  *)

  method redirect : ?cookie:Cookie.cookie -> ?cookies:Cookie.cookie list ->
    ?cookie_cache:bool -> string -> 'a
    (** [#redirect ?cookie ?cookies url] quits the current cgi
  script and send to the client a redirection header to [url]. *)

  method url : unit -> string
    (** Return the URL of the script. *)

  method param : string -> string
  (** [#param name] returns the "first" value of the parameter
[name].  @raise Not_found if [name] does not designate a valid
parameter. *)

  method param_all : string -> string list
    (** [#param_all name] returns all the values of the parameter
  [name].  @raise Not_found if [name] does not designate a
  valid parameter. *)

  method param_exists : string -> bool
    (** Return true iff the named parameter exists. *)

  method param_true : string -> bool
  (** This method returns false if the named parameter is missing,
is an empty string, or is the string ["0"]. Otherwise it
returns true. Thus the intent of this is to return true in the
Perl sense of the word.  If a parameter appears multiple
times, then this uses the first definition and ignores the
others. *)

  method params : (string * string) list
    (** Return an assoc-list mapping name -> value for all parameters.
  Note that CGI scripts may have multiple values for a single name. *)

  method is_multipart : bool
    (** Returns true iff the request was a [multipart/form-data]
  [POST] request.  Such requests are used when you need to
  upload files to a CGI script.  *)

  method upload : string -> CgiTypes.upload_data
    (** For multipart forms only.  Returns the full upload data passed
  by the browser for a particular parameter.
  @raise Not_found is no such parameter exists.  *)

  method upload_all : string -> CgiTypes.upload_data list
    (** For multipart forms only.  As for [#upload], but returns all
  uploads.  *)

  method cookie : string -> Cookie.cookie
    (** Return the named cookie, or throw [Not_found]. *)

  method cookies : Cookie.cookie list
    (** Return a list of all cookies passed to the script. *)

  method log : (unit, unit, string, unit) format4 -> unit
    (** [log s] Log the message [s] into the webserver log. *)

  method request : Request.t
    (** Returns the original request object (passed in the constructor). *)
end


val random_sessionid : unit -> bytes
  (** Generates a 128 bit (32 hex digits) random string which can be
used for session IDs, random cookies and so on.  The string
returned will be very random and hard to predict, at least if
your platform possesses /dev/urandom *)


module Args :
sig
  val parse : string -> (string * string) list
    (** [parse qs] parses up a standard CGI query string (such as
  ["a=1&b=2"]), and returns the list of name, value pairs.  This
  is a helper function.  The [cgi] class does this parsing for
  you, so you shouldn't need to use this function unless you're
  doing something out of the ordinary.  *)

  val make : (string * string) list -> string
    (** [make bindings] returns a query string from the list
  [bindings] of name, value pairs.  For example, [make
  [("a", "1"); ("b", "2")]] returns ["a=1&b=2"]. *)
end

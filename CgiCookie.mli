(* File: CGICookie.mli

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

(** Generate and parse cookies *)
class cookie :
  name:string -> value:string -> max_age:int option ->
  domain:string -> path:string -> secure:bool ->
object
  method name : string
    (** Return the name of the cookie. *)
  method value : string
    (** Return the value of the cookie. *)
  method max_age : int option
    (** Lifetime of the cookie in seconds. *)
  method domain : string
    (** Return the domain of the cookie, or "" if not set. *)
  method path : string
    (** Return the path of the cookie, or "" if not set. *)
  method secure : bool
    (** Return true if the cookie is a secure cookie. *)

  method set_name : string -> unit
    (** Set the name of the cookie. *)
  method set_value : string -> unit
    (** Set the value of the cookie. *)
  method set_max_age : int option -> unit
    (** [#set_max_age (Some s)] set the lifetime of the cookie to
  [s] seconds [s].  [#set_max_age None] means that the cookie
  will be discarded when the client broser exits. *)
  method set_domain : string -> unit
    (** Set the domain of the cookie. *)
  method set_path : string -> unit
    (** Set the path of the cookie. *)
  method set_secure : bool -> unit
    (** Set the cookie as a secure cookie.  Secure cookies are only
  transmitted to HTTPS servers. *)

  method to_string : string
    (** Return the string representation of the cookie. *)
end

val cookie : ?max_age:int -> ?domain:string -> ?path:string ->
  ?secure:bool -> string -> string -> cookie
  (** [cookie ?expires ?domain ?path name value] creates a cookie
with name [name] and value [value].

@param max_age lifetime of the cookie in seconds (default: none).
@param domain  domain of the cookie (default: "").
@param path    path of the cookie (default: "").
@param secure  whether the cookie is secure (default: [false]).
  *)

val parse : string -> cookie list
  (** [parse header] parse zero or more cookies.  Normally [header]
comes from a "Cookie: header" field. *)

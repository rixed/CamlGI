(* File: CgiCookie.ml

   Objective Caml Library for writing (F)CGI programs.

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

open CgiCommon

type same_site = Strict | Lax

let string_of_same_site = function
  | Strict -> "Strict"
  | Lax -> "Lax"

class cookie ~name ~value ~max_age ~domain ~path ~secure ?same_site () =
object (self)
  val mutable name = name
  val mutable value = value
    (*     val mutable comment = comment *)
  val mutable domain = domain
  val mutable max_age = max_age
  val mutable path = path
  val mutable secure = secure

  method name = name
  method value = value
  method domain = domain
  method max_age = max_age
  method path = path
  method secure = secure

  method set_name v = name <- v
  method set_value v = value <- v
  method set_domain v = domain <- v
  method set_max_age v = max_age <- v
  method set_path v = path <- v
  method set_secure v = secure <- v

  method to_string =
    let buf = Buffer.create 128 in
    if String.length name > 0 && String.unsafe_get name 0 = '$' then
      (* TRICK: names cannot start with '$', so if it does  add '+'
         in front to protect it. '+' will be decoded as space, then
         stripped. *)
      Buffer.add_char buf '+';
    Buffer.add_string buf (encode_cookie name);
    Buffer.add_char buf '=';
    Buffer.add_string buf (encode_cookie value);
    (* We do not encode the domain and path because they will be
       interpreted by the browser to determine whether the cookie
       must be sent back. *)
    if domain <> "" then begin
      Buffer.add_string buf "; Domain=";
      Buffer.add_string buf domain;
    end;
    if path <> "" then begin
      Buffer.add_string buf "; Path=";
      Buffer.add_string buf path;
    end;
    if secure then Buffer.add_string buf "; Secure";
    begin match max_age with
    | None -> ()
    | Some m ->
        Buffer.add_string buf "; Max-Age=";
        Buffer.add_string buf (if m >= 0 then (string_of_int m) else "0");
    end;
    begin match same_site with
    | None -> ()
    | Some ss ->
        Buffer.add_string buf "; SameSite=";
        Buffer.add_string buf (string_of_same_site ss)
    end;
    Buffer.contents buf
end


let cookie ?max_age ?(domain="") ?(path="") ?(secure=false) ?same_site name value =
  new cookie ~name ~value ~domain ~max_age ~path ~secure ?same_site ()


let parse =
  let make_cookie s =
    let name, value =
      let b = Bytes.of_string s in
      try
        let i = Bytes.index b '=' in
        (* FIXME: Must support quoted strings? *)
        (* FIXME: $Version, $Path, $Domain *)
        (* Here it is important that we strip heading and trailing spaces *)
        decode_range b 0 i,
        decode_range b (succ i) (Bytes.length b)
      with
        Not_found ->
          decode_range b 0 (Bytes.length b), "" in
    cookie name value in
  fun header ->
    if header = "" then []
    else List.map make_cookie (rev_split ';' header)

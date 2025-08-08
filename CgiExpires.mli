(* File: CGIExpires.mli

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
val make : int -> string
  (** [make s] generates an a date [s] seconds from now in fixed
format (RFC 1123).  [s] may be negative.  The date format is
suitable used for e.g. a HTTP 'Expires' header -- if [s < 0],
it means the page expires in the past, and should be removed
from content caches.  *)
val past : unit -> string
  (** Generate an date in the past (in theory this forces caches
along the way to remove content).  *)
val short : unit -> string
  (** Generate a date now + 5 minutes.  This can typically be used
for pages containing news which is updated frequently.  *)
val medium : unit -> string
  (** Generate a date now + 24 hours.  This can be used for content
generated from a database which doesn't change much.  *)
val long : unit -> string
  (** Generate a date now + 2 years.  This should be used for
content which really will never change.  *)


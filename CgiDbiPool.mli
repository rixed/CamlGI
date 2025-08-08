(* File: CGIDbiPool.mli

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

module type DbiDriverT =
sig
  type connection
  val connect : ?host:string -> ?port:string ->
    ?user:string -> ?password:string -> string -> connection
  val close : connection -> unit
  val closed : connection -> bool
  val commit : connection -> unit
  val ping : connection -> bool
  val rollback : connection -> unit
end


module DbiPool(Dbi_driver : DbiDriverT) :
  sig
     type connection = Dbi_driver.connection
     val get : Cgi.Request.t ->
 ?host:string -> ?port:string -> ?user:string -> ?password:string ->
 string -> connection
   end
  (** [module MyPool = DbiPool(Dbi_postgresql)] creates a pool of
PostgreSQL database handles.  To use them:

[let dbh = MyPool.get request "database_name"]

Returns an unused or newly created [Dbi.connection] handle
[dbh] from the pool of database handles which is valid until
the end of the current request.

The parameters uniquely identify the database name.  Separate
pools are maintained for each combination of parameters.

The connection is automatically returned to the pool at the end of
the current request.  After this time the connection may be
given away to another user.  For this reason, the calling code must
NEVER stash the connection across requests (instead, call
[get] to get a new handle each time).

On returning the handle to the pool, the pool performs a
ROLLBACK operation on the handle, thus losing any changes
(INSERT, etc.) made to the database.  If the program wants to
preserve changes, it must perform a COMMIT operation itself,
by calling [Dbi.connection.commit].  *)


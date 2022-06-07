include "lib.mzn";
include "preamble.mzn";

%The day assigned to each presentation
array[1..N]of var 1..Y: D ; 
%Ordering position of the event in the day
array[1..N]of var 1..Max_per_day: M ;
%Room assigned to each event
array[1..N]of var 1..X: R ;

constraint exists(ev in 1..N)(D[ev]=1 /\ M[ev]=1 /\ R[ev]=1) ;

% Domain propagation
constraint forall(e1 in 1..N, e2 in same_day_room(e1) where e1<e2)( M[e1]!=M[e2]) ::domain;

constraint forall(ev in 1..N)(
  sum(ev1 in same_day_room(ev))
    (if in_morning(ev1) then Len[ev1] else 0 endif) <= (Break)
  /\
  sum(ev2 in same_day_room(ev))
    (if not in_morning(ev2) then Len[ev2] else 0 endif) <= (Noon-End)
);

constraint forall(e in 1..N)(
  if is_last_day(e) then 
    forall(pos in 1..M[e])(exists(ev in same_day_room(e))(M[ev]=pos))
  endif
);
/* About annotations : 
 *
 * first_fail -> assign variable with smallest domain
 * indomain_main -> choose smallest value in variable domain (try to assign early days and positions)
 */
%solve ::int_search(D, first_fail, indomain_min) ::int_search(M, first_fail, indomain_min) satisfy;
%output [show(Max_per_day)++"\n"++show(Len)++"\n"++show(D)++"\n"++show(M)++"\n"];
include "interest.mzn"; 


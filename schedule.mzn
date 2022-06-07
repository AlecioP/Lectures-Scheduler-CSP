include "lib.mzn";
include "preamble.mzn";

%The day assigned to each presentation
array[1..N]of var 1..Y: D;
%Ordering position of the event in the day
array[1..N]of var 1..Max_per_day: M;
%Room assigned to each event
array[1..N]of var 1..X: R;


constraint exists(ev in 1..N)(D[ev]=1 /\ M[ev]=1 /\ R[ev]=1);

constraint forall(e1 in 1..N, e2 in 1..N where e1<e2 /\ D[e1]=D[e2] /\ R[e1]=R[e2] )( M[e1]!=M[e2]);

constraint forall(ev in 1..N)(
  sum(ev1 in 1..N)
    (if D[ev1]=D[ev] /\ R[ev1]=R[ev] /\ in_morning(ev1) then Len[ev1] else 0 endif) <= (Break)
  /\
  sum(ev2 in 1..N)
    (if D[ev2]=D[ev] /\ R[ev2]=R[ev] /\ not in_morning(ev2) then Len[ev2] else 0 endif) <= (Noon-End)
);

constraint forall(e in 1..N)(
  if is_last_day(e) then 
    forall(pos in 1..M[e])(exists(ev in 1..N)(D[ev]=D[e] /\ R[ev]=R[e] /\ M[ev]=pos))
  endif
);

%solve satisfy;
include "interest.mzn"; 

output [show(Max_per_day)++"\n"++show(Len)++"\n"++show(D)++"\n"++show(M)++"\n"];
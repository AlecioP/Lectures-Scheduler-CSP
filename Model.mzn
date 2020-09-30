
%Total number of presentations
int: N;
%Total number of available meeting rooms
%int: X;
%Total number of available days
int: Y;
%Presentations duration
array[1..N]of int : Len;

%The day assigned to each presentation
array[1..N]of var 1..Y: D;

array[1..N]of var 1..N: M;

array[1..N]of var 1..N: T;

constraint forall(ev in 1..N)(
    let{
        var int: partial=sum(x in 1..N)(if D[ev]==D[x] /\ M[x]<M[ev] then Len[x] else 0 endif)
    }in
    if partial < 240 /\ partial+Len[ev]<240 then
          T[ev]=partial
    elseif partial < 240 /\ partial+Len[ev]>=240 then
          T[ev]=240
    elseif partial > 240 then
          T[ev]=partial
    else true endif
    
);

%All different in the same day (i<j to break symmetry)
constraint forall(i in 1..N,j in 1..N where D[i]=D[j] /\ i<j)( M[i]!=M[j]);
constraint forall(day in 1..Y)(
forall(ev in 1..N where D[ev]=day)(
if not exists(ev1 in 1..N)(D[ev]=D[ev1] /\ M[ev1]=M[ev]+1) then
      not exists(ev2 in 1..N)(D[ev]=D[ev2] /\ M[ev2]>M[ev]) 
endif
)
);
constraint forall(day in 1..Y)(
if exists(ev in 1..N)(D[ev]=day)then
    exists(ev1 in 1..N)(D[ev1]=day /\ M[ev1]=1)
endif
);

constraint forall(i in 1..N)(T[i]<600 /\ T[i]+Len[i]<600);

solve satisfy;

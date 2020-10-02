int : Break;
int : End;
int : Noon = End-Break;
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
%%%
array[1..N]of var 1..N: M;

constraint assert(N>0,"Error: num presentations");
%constraint assert(X>0,"Error: num rooms");
constraint assert(Y>0,"Error: num days");
constraint forall(i in 1..N)(assert(Len[i]>0,"Error: Len"++show(i)));

%All different in the same day (i<j to break symmetry)
constraint forall(i in 1..N,j in 1..N where D[i]=D[j] /\ i<j)( M[i]!=M[j]);
%No solution where exists one day with M containing 3 and 5 but not 4 
constraint forall(day in 1..Y)(
forall(ev in 1..N where D[ev]=day)(
if not exists(ev1 in 1..N)(D[ev]=D[ev1] /\ M[ev1]=M[ev]+1) then
      not exists(ev2 in 1..N)(D[ev]=D[ev2] /\ M[ev2]>M[ev]) 
endif
)
);
%No solution where exists one day with M containing 2 but not 1
constraint forall(day in 1..Y)(
if exists(ev in 1..N)(D[ev]=day)then
    exists(ev1 in 1..N)(D[ev1]=day /\ M[ev1]=1)
endif
);

constraint forall(i in 1..Y)(
        sum(j in 1..N)(if D[j]==i then Len[j] else 0 endif )<End
);

constraint forall(i in 1..Y)(
      forall(j in 1..N where D[j]=i)(
      let{var int : partial = sum(x in 1..N)(if D[j]==D[x] /\ M[x]<M[j] then Len[x]else 0 endif)}in
         if partial < Break /\ partial+Len[j]>=Break then
               /*(240-partial)+ */
               sum(z in 1..N)(if D[j]==D[z] /\ M[z]>=M[j] then Len[z] else 0 endif)<Noon
         endif
      )
);

solve satisfy;
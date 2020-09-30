
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

%All different in the same day (i<j to break symmetry)
constraint forall(i in 1..N,j in 1..N where D[i]=D[j] /\ i<j)( M[i]!=M[j]);

constraint forall(i in 1..Y)(
        sum(j in 1..N)(if D[j]==i then Len[j] else 0 endif )<420
);

constraint forall(i in 1..Y)(
      forall(j in 1..N where D[j]=i /\ not exists(j1 in 1..N)(D[j]=D[j1] /\ j1<j))(
      let{var int : partial = sum(x in 1..N)(if D[j]==D[x] /\ M[x]<M[j] then Len[x]else 0 endif)}in
         if partial < 240 /\ partial+Len[j]>=240 then
               /*(240-partial)+ */
               sum(z in 1..N)(if D[j]==D[z] /\ M[z]>=M[j] then Len[z] else 0 endif)<180
         endif
      )
);

solve satisfy;

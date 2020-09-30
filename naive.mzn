
%%%%%%%%%%%%%%%%%---PARAMETERS---%%%%%%%%%%%%%%%%%

%Total number of presentations
int: N;
%Total number of available meeting rooms
int: X;
%Total number of available days
int: Y;
%Total number of participants
%int: P;
%Presentations duration
array[1..N]of int : Len;
%Presenter ID (1..P) for i-th presentation (1<i<N)
%array[1..N]of int : H;
%Participants interest (0<I[j]<5)
%array[1..P,1..N]of int : I;

%%%%%%%%%%%%%%%%%---DECISION VARIABLES---%%%%%%%%%%%%%%%%%

%The room assigned to each presentation
array[1..N]of var 1..X: R;
%The day assigned to each presentation
array[1..N]of var 1..Y: D;
%The start time assigned to each presentation 
%(expressed in minutes from 9:00 am)
array[1..N]of var 0..479: M;

%Wheter the participant i attends presentation j
%array[1..P,1..N]of var 0..1 : Participation;

%%%%%%%%%%%%%%%%%---CONSTRAINTS---%%%%%%%%%%%%%%%%%
constraint assert(N>0,"Error: num presentations");
constraint assert(X>0,"Error: num rooms");
constraint assert(Y>0,"Error: num days");
constraint forall(i in 1..N)(assert(Len[i]>0,"Error: Len"++show(i)));

%Alldifferent for 3-uples (R,D,M)
%constraint forall(i in 1..N,j in 1..N where i!=j)(R[i]!=R[j] \/ D[i]!=D[j] \/ M[i]!=M[j]);

%--------------------M[j]++++++P[j]+++++++M[j]+Len[j]-------------------Time->

%For each couple of presentations on the same day and same room,
%check that the whole first presentation can be done before the start 
%of the second one or starts after the end of the second one

constraint forall (i in 1..N,j in 1..N where D[i]==D[j] /\ R[i]=R[j] /\ i!=j)(
                   (M[i]<M[j] /\ (M[i]+Len[i]) < M[j]) \/
                   (M[i]>=(M[j]+Len[j]))
);

%Each presentation cannot start between 1:00 pm and 2:00 pm
constraint forall(i in 1..N)(M[i]<=240 \/ M[i]>=300);

%Each presentation in the morning has to end before the break at 1:00 pm
constraint forall (i in 1..N where M[i]<=240)(M[i]+Len[i] <= 240);

%Each presentation in the afternoon has to end before 5:00 pm
constraint forall (i in 1..N where M[i]>=300)(M[i]+Len[i] <= 480);

%Each participant cannot attend 2 events on 
%the same day and same time but in 2 different rooms
% constraint forall (i in 1..P)(
%             forall (c1 in 1..N,c2 in 1..N 
%                     where Participation[i,c1]=1 /\ 
%                           Participation[i,c2]=1 /\ 
%                           c1 != c2 /\ R[c1]!=R[c2] /\ D[c1]=D[c2] 
                         
%                    )%FORALL_2
%                    (%BODY FORALL_2
%                    (M[c1]<M[c2] /\ (M[c1]+Len[c1]) <= M[c2]) \/
%                              (M[c1]>=(M[c2]+Len[c2]))
%             )
% );

% constraint forall (i in 1..N)(
%       forall(j in 1..P where j=H[i])(
%        %Row j-th of matrix Participation represents 
%        %the bonds to the events of the Presenter of the j-th event
       
%            forall(c in 1..N where i!=c /\ Participation[j,c]=1 /\ D[i]=D[c] /\ R[i]!=R[c])(
%                (M[c]<M[i] /\ (M[c]+Len[c]) <= M[i]) \/
%                (M[c]>=(M[i]+Len[i]))
%            )
%       )
% );
solve satisfy;
%solve maximize sum(i in 1..P,j in 1..N)(I[i,j]*Participation[i,j]);

%Presentation i Day D, Room R, Time (M/60+9) : (M%60 + 00) -1
output[
  "Presentation " ++ show(i) ++ " = Day " ++ show(D[i])++ " Room " ++ show(R[i]) ++
  " Time " ++ show( M[i] div 60+9) ++ " : " ++ show(M[i] mod 60 )++"\n"
| i in 1..N
];
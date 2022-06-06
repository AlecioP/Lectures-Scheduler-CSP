import csv

D = []
P = []
L = []

with open('minizinc.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter=',', quoting=csv.QUOTE_NONNUMERIC)
    rn = 0
    for r in reader:
        for i in range(0,len(r)):
            if(rn==0):#Reading Lengths array
                L.append(r[i])
            if(rn==1):#Reading days array
                D.append(r[i])
            if(rn==2):#Reading day positions array
                P.append(r[i])
        rn+=1

for day in range(1,int(max(D)+1)):
    F = []
    ID = []
    for i in range(0,len(P)):
        if(D[i]==day):
            F.append(P[i])
            ID.append(i)
    #Bubble sort
    for i in range(0,len(F)):
        for j in range(0,len(F)):
            if(F[i]<F[j] and i>j ):
                tmp = F[i]
                F[i]=F[j]
                F[j]=tmp
                tmp = ID[i]
                ID[i]=ID[j]
                ID[j]=tmp
    
    partial = 0
    print("Day "+str(day)+" : ")
    for i in range(0,len(F)):
        if(partial<240 and partial + L[ID[i]] >=240):
            partial=300+L[ID[i]]
            print("Event "+str(i)+" at 14:00 . Length : "+str(int(L[ID[i]])//60)+"h "+str(int(L[ID[i]])%60)+"m")
        else:
            print("Event "+str(i)+" at "+str(int(partial)//60+9)+":"+str(int(partial)%60)+" . Length : "+str(int(L[ID[i]])//60)+"h "+str(int(L[ID[i]])%60)+"m")
            partial += L[ID[i]]


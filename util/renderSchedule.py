import csv
import argparse

parser = argparse.ArgumentParser(
prog="Visualizer", 
description="Create human readable visualization of scheduling contained in input file.",
epilog="Author : https://github.com/AlecioP")

parser.add_argument("--schedule","-s",
dest="schedule_file",
help="file containing the scheduling (default : ./minizinc.csv)",
metavar="File",
default="minizinc.csv")


args = parser.parse_args()

# Since Minizinc output has brackets in it
# Just use SED command to remove those
import os
CMD = f"sed -Ee 's/[][]//g' -i {args.schedule_file}"
os.system(CMD)

D = []
P = []
L = []

with open(args.schedule_file, newline='\n') as csvfile:
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
    print(f"Day {day} : ")
    for i in range(0,len(F)):
        if(partial<240 and partial + L[ID[i]] >=240):
            partial=300+L[ID[i]]
            print(f" E{ID[i]+1} 14:00 {int(L[ID[i]])//60}h{int(L[ID[i]])%60}m -> |",end="")
        else:
            print(f" E{ID[i]+1} {int(partial)//60+9}:{int(partial)%60} {int(L[ID[i]])//60}h{int(L[ID[i]])%60}m -> |",end="")
            partial += L[ID[i]]
    print("")

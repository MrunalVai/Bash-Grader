#This awk file will assume that total is not in first line of main.csv. rest logic is typical.

BEGIN{
    FS=",";
    OFS=",";
}
{
    s=0
    if(NR==1){
        print $0,"total"
    }
    if(NR>1){
        for (i=3;i<=NF;i++){
            s+=$i
        }
        print $0,s
    }
}

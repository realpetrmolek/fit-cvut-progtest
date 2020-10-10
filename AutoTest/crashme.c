#include <stdio.h>

void lol() {
    lol();
}

int main()
{
    int n;
    scanf("%d",&n);
    if(n>100)lol();
    
    return 0;
}
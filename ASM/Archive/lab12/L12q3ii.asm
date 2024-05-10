org 100h

;divide number by 10
;fetch quotient
;compare with one/zero
;update counter accordingly
;repeat

mov ax, 4c00h
int 21h

num1: dw 43658
num2: dw 31913 

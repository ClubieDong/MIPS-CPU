addi $t0,$zero,7 # a = 7 
addi $t1,$zero,0 # count = 0
while:
beq $t0,$zero,L1 # while (a > 0)
addi $t1,$t1,1   # ++count
addi $t2,$t0,-1  # a = a & (a ¨C 1)
and $t0,$t0,$t2
j while
L1:

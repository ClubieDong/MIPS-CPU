
while:
addiu $t1,$zero,10
addiu $t2,$zero,0x0
addiu $t3,$zero,10
addiu $t4,$zero,1
addiu $t7,$zero,4
addiu $v0,$zero,0
for:
slt $v1,$v0,$t3
beq $v1,0,after1
addi $v0,$v0,1
sw $t1,($t2)
sub $t1,$t1,$t4
addi $t2,$t2,4
j for
after1:
addiu $t1,$zero,10
addiu $v0,$zero,0
addiu $a0,$zero,0
sub $t3,$t3,$t4
bubble1:
addiu $t2,$zero,0x0
slt $v1,$v0,$t3
beq $v1,0,after2
addi $v0,$v0,1
addiu $a0,$zero,0
bubble2:
slt $v1,$a0,$t3
beq $v1,0,bubble1
addi $a0,$a0,1
lw $t1,($t2)
lw $t5,4($t2)
addi $t2,$t2,4
slt $v1,$t1,$t5
beq $v1,1,bubble2
sub $t2,$t2,$t7
ori $t6,$t1,0
and $t1,$t1,$zero
or $t1,$t1,$t5
and $t5,$t5,$zero
or $t5,$t5,$t6
sw $t1,($t2)
sw $t5,4($t2)
add $t2,$t2,$t7
j bubble2
after2:
addiu $v0,$zero,0
addiu $t2,$zero,0x0
result:
slt $v1,$v0,$s3
beq $v1,0,afterall
addi $v0,$v0,4
lw $t1 ($t2)
addi $t2,$t2,4
j result
afterall:
lui $t1,0x0100
xor $t1,$t1,$t1
addiu $t1,$zero,10
j end
end:
j end

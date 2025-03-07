addi x5, x0, 63
add x5, x5, x5
sub x6, x0, x5
sd x6, 17(x0)
ld x7, 17(x0)
add x8, x5, x5
sd x7, 0(x8)
ld x9, 0(x8)
addi x10, x0, 17
add x11, x10, x0
ld x12, 0(x11)
add x13, x5, x5
addi x31, x0, -1
add x14, x13, x13
sub x15, x8, x5
add x16, x15, x14
add x17, x14, x15
add x18, x16, x17
add x18, x18, x17
add x19, x18, x0
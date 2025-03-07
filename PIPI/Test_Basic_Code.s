addi x3, x0, 10
addi x4, x3, 50
sub x5, x4, x3
and x6, x4, x5
or x7, x6, x5
add x3, x3, x3
add x3, x3, x3
add x3, x3, x3
add x3, x3, x3
sd x3, 0(x7)
ld x8, 0(x7)
sd x3, 10(x7)
ld x9, 10(x7)
ld x10, 10(x7)
sd x10, 14(x7)
ld x11, 14(x7)
add x12, x11, x11
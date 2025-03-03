addi x1, x0, 0                           # 0x00000093
addi x4, x0, 10                          # 0x00a00213
sd x4, 0(x1)                             # 0x0040b023
addi x4, x0, 25                          # 0x01900213
sd x4, 1(x1)                             # 0x0040b0a3
addi x4, x0, 15                          # 0x00f00213
sd x4, 2(x1)                             # 0x0040b123
addi x4, x0, 69                          # 0x04500213
sd x4, 3(x1)                             # 0x0040b1a3
addi x4, x0, 30                          # 0x01e00213
sd x4, 4(x1)                             # 0x0040b223
addi x3, x0, 0                           # 0x00000193
addi x5, x0, 5                           # 0x00500293
add x7, x1, x0                           # 0x000083b3
addi x2, x0, 1818                        # 0x71a00113
beq x3, x5, 14                           # 0x00518763
ld x8, 0(x7)                             # 0x0003b403
sub x9, x8, x2                           # 0x402404b3
beq x9, x0, 10                           # 0x00048563
addi x3, x3, 1                           # 0x00118193
addi x7, x7, 1                           # 0x00138393
beq x0, x0, -12                          # 0xfe000ae3
addi x3, x0, -1                          # 0xfff00193
addi x1, x0, 1024                        # 0x40000093
addi x3, x0, 55                          # 0x03700193
beq x3, x0, 10                           # 0x00018563
add x4, x1, x1                           # 0x00108233
add x1, x4, x0                           # 0x000200b3
addi x3, x3, -1                          # 0xfff18193
beq x0, x0, -8                           # 0xfe000ce3
sd x1, 0(x5)                             # 0x0012b023
ld x10, 0(x5)                            # 0x0002b503
sd x6, 3(x5)                             # 0x0062b1a3
ld x11, 3(x5)                            # 0x0032b583
beq x4, x5, 4                            # 0x00520263
beq x0, x0, 0                            # 0x00000063
add x13, x1, x10                         # 0x00a086b3
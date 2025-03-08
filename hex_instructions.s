addi x5, x0, 63                          # 0x03f00293
add x5, x5, x5                           # 0x005282b3
sub x6, x0, x5                           # 0x40500333
sd x6, 17(x0)                            # 0x006038a3
ld x7, 17(x0)                            # 0x01103383
add x8, x5, x5                           # 0x00528433
sd x7, 0(x8)                             # 0x00743023
ld x9, 0(x8)                             # 0x00043483
addi x10, x0, 17                         # 0x01100513
add x11, x10, x0                         # 0x000505b3
ld x12, 0(x11)                           # 0x0005b603
add x13, x5, x5                          # 0x005286b3
beq x13, x8, 4                           # 0x00868263
addi x31, x0, -1                         # 0xfff00f93
add x14, x13, x13                        # 0x00d68733
sub x15, x8, x5                          # 0x405407b3
add x16, x15, x14                        # 0x00e78833
add x17, x14, x15                        # 0x00f708b3
add x18, x16, x17                        # 0x01180933
add x18, x18, x17                        # 0x01190933
add x19, x18, x0                         # 0x000909b3
ld x20, 0(x11)                           # 0x0005ba03
sd x20, 121(x11)                         # 0x0745bca3
ld x21, 121(x11)                         # 0x0795ba83
sd x10, 1(x0)                            # 0x00a030a3
ld x22, 1(x0)                            # 0x00103b03
sd x21, 1(x22)                           # 0x015b30a3
ld x23, 1(x22)                           # 0x001b3b83
ld x24, 121(x11)                         # 0x0795bc03
sub x25, x0, x24                         # 0x41800cb3
ld x26, 1(x0)                            # 0x00103d03
beq x10, x26, 4                          # 0x01a50263
sub x31, x0, x15                         # 0x40f00fb3
ld x27, 1(x0)                            # 0x00103d83
ld x28, 1(x27)                           # 0x001dbe03
addi x29, x10, 1                         # 0x00150e93
add x0, x0, x0                           # 0x00000033
ld x30, 0(x29)                           # 0x000ebf03
add x0, x0, x0                           # 0x00000033
add x4, x30, x30                         # 0x01ef0233
add x0, x0, x0                           # 0x00000033
add x0, x0, x0                           # 0x00000033
add x1, x4, x0                           # 0x000200b3
ld x2, 1(x0)                             # 0x00103103
add x0, x0, x0                           # 0x00000033
add x0, x0, x0                           # 0x00000033
add x3, x2, x0                           # 0x000101b3
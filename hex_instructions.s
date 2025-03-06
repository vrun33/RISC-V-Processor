addi x3, x0, 10                          # 0x00a00193
addi x4, x3, 50                          # 0x03218213
sub x5, x4, x3                           # 0x403202b3
and x6, x4, x5                           # 0x00527333
or x7, x6, x5                            # 0x005363b3
add x3, x3, x3                           # 0x003181b3
add x3, x3, x3                           # 0x003181b3
add x3, x3, x3                           # 0x003181b3
add x3, x3, x3                           # 0x003181b3
sd x3, 0(x7)                             # 0x0033b023
ld x8, 0(x7)                             # 0x0003b403
sd x3, 10(x7)                            # 0x0033b523
ld x9, 10(x7)                            # 0x00a3b483
ld x10, 10(x7)                           # 0x00a3b503
sd x10, 14(x7)                           # 0x00a3b723
ld x11, 14(x7)                           # 0x00e3b583
add x12, x11, x11                        # 0x00b58633
add x0, x0, x0                           # 0x00000033
add x0, x0, x0                           # 0x00000033
add x0, x0, x0                           # 0x00000033
add x0, x0, x0                           # 0x00000033
add x0, x0, x0                           # 0x00000033
add x0, x0, x0                           # 0x00000033
add x0, x0, x0                           # 0x00000033
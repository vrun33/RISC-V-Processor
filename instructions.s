addi x1, x0, 10       
addi x2, x0, 0        
addi x3, x0, 0        
addi x4, x0, 1        
sd x3, 0(x2)          
addi x2, x2, 1        
sd x4, 0(x2)          
addi x2, x2, 1        
addi x5, x0, 2        
beq x5, x1, 16        
add x6, x3, x4    	  
sd x6, 0(x2)          
addi x2, x2, 1        
addi x5, x5, 1        
add x3, x0, x4        
add x4, x0, x6        
beq x0, x0, -14       
add x2, x0, x0        
ld x10, 0(x2)         
ld x11, 1(x2)
ld x12, 2(x2)
ld x13, 3(x2)
ld x14, 4(x2)
ld x15, 5(x2)
ld x16, 6(x2)
ld x17, 7(x2)
ld x18, 8(x2)
ld x19, 9(x2)
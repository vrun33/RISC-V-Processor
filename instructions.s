addi x1, x0, 0
addi x4, x0, 10      
sd x4, 0(x1)
addi x4, x0, 25      
sd x4, 1(x1)
addi x4, x0, 15      
sd x4, 2(x1)
addi x4, x0, 69      
sd x4, 3(x1)
addi x4, x0, 30      
sd x4, 4(x1)
addi x3, x0, 0       
addi x5, x0, 5       
add x7, x1, x0       
addi x2, x0, 1818      
beq x3, x5, 14     
ld x8, 0(x7)          
sub x9, x8, x2        
beq x9, x0, 10        
addi x3, x3, 1        
addi x7, x7, 1        
beq x0, x0, -12         
addi x3, x0, -1 
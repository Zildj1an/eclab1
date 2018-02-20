
	.equ COEF1, 3483
	.equ COEF2, 11718
	.equ COEF3, 1183

	.text

	.global rgb2gray
	.global div16384
	.global apply_gaussian
	.global countWhite
	.extern gaussian

rgb2gray:
	//We are using 2 registers above R3, R4 and R5 so there is a need for a push to dont erase the previous values
	push {R4,R5,lr}

	//in R0 there is the pointer to the char
	//dest = (3483*orig.R + 11718*orig.G + 1183*orig.B) /16384;

	//1st bit is R
	ldr  R1, =COEF1	//3483
	ldrb R2, [R0]	//orig.R
	mul  R3, R1, R2	//3483*orig.R		R3

	//2nd bit is G
	ldr  R1, =COEF2	//11718
	ldrb R2, [R0,#1]//orig.G
	mul  R4, R1, R2	//11718*orig.G		R4

	//3rd bit is B
	ldr  R1, =COEF3	//1183
	ldrb R2, [R0,#2]//orig.G
	mul  R5, R1, R2	//1183*orig.B		R5

	add R3, R3, R4	//3483*orig.R + 11718*orig.G
	add R3, R3, R5	//3483*orig.R + 11718*orig.G + 1183*orig.B

	mov R0, R3		//to pass the number to be divided t the subrutine

	bl div16384 	//(3483*orig.R + 11718*orig.G + 1183*orig.B) /16384
					//as a aresult of the subrutine the result = ((3483*orig.R + 11718*orig.G + 1183*orig.B) /16384) is in R0
	pop {R4,R5,pc}


div16384:
		//R0 / 16384
		 ldr R1, =16384 //we load in R1 the value to divide
		 mov R2, #0		//result of division RES
		 mov R3, R1		//multiples of 16384 ACUM

	loop:cmp r3, r0		//is the acumulative of multiples greater or equal than the argument?
	 	 bge fin		//if it is, division done
		 add r3,r3,r1	//if doesnt, the accumulative grows 16384
		 add r2,r2,#1	//and the result of the diviion is one unit greater
		 b   loop		//and compare once more
	fin: mov r0,r2		//we place the resulltof the division on R0 (STANDARDS)

	 	 mov pc, lr		//restore program counter


apply_gaussian:
			push {R4-R7 , lr}	//we use registers up to R7
		 //when the function is called the arguments are:
			//R0 - imagenGris[]
			//R1 - imagenGauss[]
			//R2 - N
			//R3 - M

		//redistribution of registers
			MOV R5, R1	//imagen gaus, result in R5
			MOV R1, R2	//N in R1 WIDTH
			MOV R2, R3	//M in R2 HEIGHT
			MOV R3, #0	//i index in R3

	for1:	CMP R3, R2
			BGE fin1

			MOV R4, #0	//j index; j = 0

	for2:	CMP R4, R1
			BGE fin2

			push {R0-R3}	//backup
			push {R4}
			//push {R0-R4}

			BL gaussian
			MOV R6, R0 //R6 result de gaussian

			pop {R4}
			pop {R0-R3}
			//ADD SP, SP, #4
			//pop {R0-R3}

			//im2[i * width + j]
			MUL  R7, R3, R1	// i * width
			ADD  R7, R7, R4	// R7 has (i * width + j)
			STRB R6, [R5, R7]

			ADD R4, R4, #1	//j++
			B	for2

	fin2:	ADD R3, R3, #1	//i++
			B for1

	fin1:	pop {R4 - R7, pc}
			//MOV PC, LR

	//int countWhite(unsigned char im[], int size){
countWhite: push {R4, fp}
			add fp, sp, #4

			MOV R2, #0 //count
			MOV R3, #0 // i
	forW:	CMP R3, R1
			BGE finW

			LDRB R4,[R0,R3]
			CMP R4, #25
			BGE increase
			ADD R2,R2, #1

	increase: ADD R3,R3, #1
			B forW

	finW:	mov R0, R2
			pop {R4, fp}
			mov pc, lr
  		.end



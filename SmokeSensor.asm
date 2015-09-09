#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h# 
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

    jmp    st1 
    db     509 dup(0)

;IVT entry for 80H
	dw     t_isr
	dw     0000
	db     508 dup(0)

st1: cli 
	; intialize ds, es,ss to start of RAM
    mov       ax,0100h
    mov       ds,ax
    mov       es,ax
    mov       ss,ax
    mov       sp,0FFFEH					
		  
	;initialize 8255
	;portA	equ	0000h
	;portB	equ 0002h
	;portC	equ	0004h
	;creg	equ	0006h

	mov al, 10010001b					; portA = input, portB = output, portC lower = input, portC upper = output
	out 0006H, al
	
	;enables the motors, rotates the motors in the clockwise direction, enables gate for clock0 for 500 clock pulses
	
	mov al, 00000000b
	out 0004H, al
	
	;8259 - 18H to 1AH
	;8259 -	enable IRO alone use AEOI	  
	mov       al,00010011b
	out       18h,al
	mov       al,80h
	out       1Ah,al
	mov       al,03h
	out       1Ah,al
	mov       al,0FEh
	out       1Ah,al
	
x11:	
	mov al, 11010000b 	
	out 0004H, al
	
	;initialize 8253
	sti				

x12:	
	
	;cnt0	equ	0010h
	;cnt1	equ	0012h
	;cnt2	equ	0014h
	;0016h	equ	0016h
	
	mov al, 00110000b
	out 0016H, al
	
	mov al, 15h
	out 0010H, al
	
	mov al, 00h
	out 0010H, al
	
	mov al,00010000b
	out 0004h,al		; port C gate enable 
	mov al, 00000000b
	out 0002h, al 	;send address 000 to ADC
	
	mov al, 01000000b
	out 0002h, al 	
	
	mov al, 01100000b
	out 0002h, al 	
	
	mov al, 01000000b
	out 0002h, al	
	
x13:	in al, 0004h	;polls for EOC signal
	and al, 01h
	cmp al, 01h
	jnz x13			;if EOC is low, loop back to x13, else proceed
	mov al, 00000000b
	out 0002h, al
	
	in al, 0000h	;since EOC is high, take the input from the ADC of smoke sensor 0
	out 0002h, al
	
	mov cl, 93h
	cmp al, cl		;compare al with an arbitrary value
	
	pushf
	pop bx
	and bx, 0080h
	cmp bx, 0000h
	jnz x0				;if al < danger level, jump to x0

	mov bl, al		
	mov al, 00h
	
	mov al, 10000000b
	out 0002h, al 	;send address 001 to ADC
	
	mov al, 11000000b
	out 0002h, al 	
	
	mov al, 11100000b
	out 0002h, al 	
	
	mov al, 11000000b
	out 0002h, al	
	
x14:	
	in al, 0004h	;polls for EOC signal
	and al, 01h
	cmp al, 01h
	mov al, 00000000b
	out 0002h, al
	
	jnz x14			;if EOC is low, loop back to x4, else proceed
	
	mov al, 00h
	
	in al, 0000h	;since EOC is high, take input from ADC of smoke sensor 1
	in al, 0000h
	out 0002h, al
	
	mov cl, 93h
	cmp al, cl		;compare al with the arbitrary value
	
	pushf
	pop bx
	and bx, 0080h
	cmp bx, 0000h
	jnz x0			

	mov al, 00000000b
	out 0002h, al
		
	mov al, 10110000b
	out 0004h, al	;rotating the motors in clockwise direction
	
	mov dl, 01h		;set state of doors, windows, valves as open

	; checking if the smoke has reduced
	
	mov al, 00000000b	
	out 0002h, al 	;send address 000 to ADC
	
	mov al, 01000000b
	out 0002h, al 	
	
	mov al, 01100000b
	out 0002h, al 	
	
	mov al, 01000000b
	out 0002h, al	
	
	
x23:	
	in al, 0004h	;polls for EOC signal
	and al, 01h
	cmp al, 01h
	jnz x23			;if EOC is low, loop back to x23, else proceed
	mov al, 00000000b
	out 0002h, al
	
	in al, 0000h	;since EOC is high, take the input from the ADC of smoke sensor 0
	out 0002h, al
	
	mov cl, 93h
	cmp al, cl		;compare al with an arbitrary value
	
	pushf
	pop bx
	and bx, 0080h
	cmp bx, 0000h
	jnz x17			;if al <= danger level, jump to x7

	

	mov bl, al		
	mov al, 00h
	
	mov al, 10000000b
	out 0002h, al 	;send address 001 to ADC
	
	mov al, 11000000b
	out 0002h, al 	
	
	mov al, 11100000b
	out 0002h, al 	
	
	mov al, 11000000b
	out 0002h, al	
	
x24:	
	in al, 0004h	;polls for EOC signal
	and al, 01h
	cmp al, 01h
	mov al, 00000000b
	out 0002h, al
	
	jnz x24			;if EOC is low, loop back to x24, else proceed
	
	mov al, 00h
	
	in al, 0000h	;since EOC is high, take input from ADC of smoke sensor 1
	in al, 0000h
	out 0002h, al
	
	mov cl, 93h
	cmp al, cl		;compare al with the arbitrary value
	
	pushf
	pop bx
	and bx, 0080h
	cmp bx, 0000h
	jnz x17			;if al <= danger level, jump to x7

	
	
	jmp x12			;if al > danger level for both smoke sensors, jump to x12
	
x17:	
	;close doors, windows and valve
		
	mov al, 11010000b
	out 0004h, al			
	
	mov dl, 00h				;set previous state bit back to 0
	jmp x0					

x0: jmp x0					; till an interrupt is raised 

t_isr: 

	; below code to be put in IVT
	
x2:	;cnt1	equ	0012h
	;cnt2	equ	0014h
	;0016h	equ	0016h
	
	mov al, 00110000b
	out 0016H, al
	
	mov al, 15h
	out 0010H, al
	
	mov al, 00h
	out 0010H, al
	
	mov al,00010000b
	out 0004h,al		; port C gate enable 

	mov al, 00000000b
	out 0002h, al 	
	
	mov al, 01000000b
	out 0002h, al 	
	
	mov al, 01100000b
	out 0002h, al 	
	
	mov al, 01000000b
	out 0002h, al	
	
x3:	in al, 0004h	;polls for EOC signal
	and al, 01h
	cmp al, 01h
	jnz x3			;if EOC is low, loop back to x3, else proceed
	mov al, 00000000b
	out 0002h, al
	
	in al, 0000h	;since EOC is high, take the input from the ADC of smoke sensor 0
	out 0002h, al
	
	mov cl, 93h
	cmp al, cl		;compare al with an arbitrary value
	
	pushf
	pop bx
	and bx, 0080h
	cmp bx, 0000h
	jnz x20			;if al < danger level, jump to x20

	mov bl, al		
	mov al, 00h
	
	mov al, 10000000b
	out 0002h, al 	;send address 001 to ADC
	
	mov al, 11000000b
	out 0002h, al 	
	
	mov al, 11100000b
	out 0002h, al 	
	
	mov al, 11000000b
	out 0002h, al	
	
x4:	in al, 0004h	;polls for EOC signal
	and al, 01h
	cmp al, 01h
	mov al, 00000000b
	out 0002h, al
	
	jnz x4			;if EOC is low, loop back to x4, else proceed
	
	mov al, 00h
	
	in al, 0000h	;since EOC is high, take input from ADC of smoke sensor 1
	in al, 0000h
	out 0002h, al
	
	mov cl, 93h
	cmp al, cl		;compare al with the arbitrary value
	
	pushf
	pop bx
	and bx, 0080h
	cmp bx, 0000h
	jnz x20			;if al < danger level, jump to x20

	;rotating the motors in clockwise direction and enabling gate 0
	
	mov al, 00000000b
	out 0002h, al
			
	mov al, 10110000b
	out 0004h, al		
	
	mov dl, 01h		;set state of doors, windows, valves as open

	; checking if the smoke has reduced

	mov al, 00000000b
	out 0002h, al 	;send address 000 to ADC
	
	mov al, 01000000b
	out 0002h, al 	
	
	mov al, 01100000b
	out 0002h, al 	
	
	mov al, 01000000b
	out 0002h, al	
	
	
x5:	in al, 0004h	;polls for EOC signal
	and al, 01h
	cmp al, 01h
	jnz x5			;if EOC is low, loop back to x5, else proceed
	mov al, 00000000b
	out 0002h, al
	
	in al, 0000h	;since EOC is high, take the input from the ADC of smoke sensor 0
	out 0002h, al
	
	mov cl, 93h
	cmp al, cl		;compare al with an arbitrary value
	
	pushf
	pop bx
	and bx, 0080h
	cmp bx, 0000h
	jnz x7

	;if al <= danger level, jump to x7

	mov bl, al
	mov al, 00h
	
	mov al, 10000000b
	out 0002h, al 	;send address 001 to ADC
	
	mov al, 11000000b
	out 0002h, al 	
	
	mov al, 11100000b
	out 0002h, al 	
	
	mov al, 11000000b
	out 0002h, al	
	
x6:	in al, 0004h	;polls for EOC signal
	and al, 01h
	cmp al, 01h
	mov al, 00000000b
	out 0002h, al
	
	jnz x6			;if EOC is low, loop back to x6, else proceed
	
	mov al, 00h
	
	in al, 0000h	;since EOC is high, take input from ADC of smoke sensor 1
	in al, 0000h
	out 0002h, al
	
	mov cl, 93h
	cmp al, cl		;compare al with the arbitrary value
	
	pushf
	pop bx
	and bx, 0080h
	cmp bx, 0000h
	jnz x7

	;if al <= danger level, jump to x7
	
	jmp x2			;if al > danger level for both smoke sensors, jump to x2 (re-initialisation condition, basically checks again)
	
x7:
	;close doors, windows and valve
	
	mov al, 11010000b
	out 0004h, al			
	
	mov dl, 00h				;set previous state bit back to 0

x20:
	iret
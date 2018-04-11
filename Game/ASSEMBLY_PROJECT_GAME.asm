bits 16
org 0x7C00

cli

mov ah , 0x02
mov al ,8
mov dl , 0x80
mov ch , 0
mov dh , 0
mov cl , 2
mov bx, startingTheCode
int 0x13
jmp startingTheCode


times (510 - ($ - $$)) db 0
db 0x55, 0xAA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
startingTheCode:
        ;
	cli
	mov edi, 0xB8000
	xor ebx,ebx;
	xor ecx,ecx;
	xor edx, edx;
	xor esi,esi;
	
	xor ax , ax  
	mov ss , ax 
	mov sp , 0xffff
      ;
main_code:
; changing the mode to graphics mode:
       mov ah , 0
       mov al , 13h
       int 10h
       ;
      call draw_pad
      call find_B
      call go_left
      
      
      
      
      
      
      
      
      
      
      
      jmp return
      ;THE FUNCTIONS:
      
      
      ;CHECKING USER INPUT [boolean check_input ()] :
      check_input:
      in al , 0x64
      and al,1
      jz no_valid_input; ma d5l 7aga
      ; d5l 7aga
      in al,0x60 ; user input
      cmp al,0x1E
      je mov_pad_down
      cmp al,0x10
      je mov_pad_up
      ; no valid input
      no_valid_input:
      mov ax,0
      ret
      mov_pad_down:
      mov ax,1
      ret
      mov_pad_up:
      mov ax,2
      ret
      
  ;MOVING THE PAD UPWARDS [void move_pad_up(p)]
      move_pad_up:
      call pad_boundry
      cmp ax,2 ; reached upper boundry
      je cant_move_up
      call delete_pad
      ;
      mov cx,[p]
      sub cx,5
      mov [p] ,cx
      ;
      call draw_pad
      cant_move_up:
      ret
      
      ;MOVING THE PAD DOWNWARDS [void move_pad_down(p)]
      move_pad_down:
      call pad_boundry
      cmp ax,1 ; reached lower boundry
      je cant_move_down
      call delete_pad
      ;
      mov cx,[p]
      add cx,5
      mov [p] ,cx
      ;
      call draw_pad
      cant_move_down:
      ret
      ;CHECKING PAD'S BOUNDRIES : [boolean pad_boundry(p)]
      pad_boundry:
      mov cx,[p]
      mov bx,200
      sub bx,25  ;200-25
      cmp cx,0
      jle upper_pad_boundry
      cmp cx,bx
      jge lower_pad_boundry
      ; no boundry reached
      mov ax,0
      ret
      lower_pad_boundry:
      mov ax,1
      ret
      upper_pad_boundry:
      mov ax,2
      ret
      ;DRAW PAD ON THE LEFT [void draw_pad (p)]
      draw_pad:
      mov dx , [p]
      mov cx , 15 
      mov bx , 25
      add bx , dx ; p + 25
      pad_draw_loop:
      cmp dx , bx
      jge end_pad_draw_loop
      
      
       mov al , 51
       mov ah , 0ch
       int 10h
      
      inc dx
      jmp pad_draw_loop
      end_pad_draw_loop: 
      ret
      
      ;DELETE PAD FROM THE LEFT [void delete_pad (p)]
      delete_pad:
      mov dx , [p]
      mov cx , 15 
      mov bx , 25
      add bx , dx ; p + 25
      pad_delete_loop:
      cmp dx , bx
      jge end_pad_delete_loop
      
      
       mov al , 0
       mov ah , 0ch
       int 10h
      
      inc dx
      jmp pad_delete_loop
      end_pad_delete_loop: 
      ret
      
      
      
      ;DRAWING A CIRCLE AT (a,b): [void draw_circle(a,b)]
      draw_circle:	

       finit
       fld dword[a] ;a
       fsub dword[five]
       fist dword[temp]
       mov cx , [temp] 
       ;
       fadd dword[five]
       fadd dword[five]
       fistp dword[temp]
       mov si,[temp]
       circle:
       cmp cx , si
       jg end_circle
       
       mov [temp] , cx
       fild dword [temp]
       fsub dword [a]
       fmul st0
       fsub dword [radius]
       fchs
       fsqrt
       fadd dword [b]
       fistp dword [temp]
       mov dx , [temp]
       mov al , 1100b
       mov ah , 0ch
       int 10h
       ;
       ;
       fld dword[b] ; b
       fadd dword[b]; 2*b
       fistp dword[temp]
       mov di,[temp]
       ;
       mov bx , dx
       sub dx , di
       neg dx
       fill_loop:
       cmp dx , bx
       jg end_fill_loop
       inc dx
       mov al , 1100b
       mov ah , 0ch
       int 10h
       jmp fill_loop
       end_fill_loop:
       inc cx
       jmp circle
       end_circle:
       ret
       
       ;DELETING CIRCLE AT a,b :[delete_circle(a,b)]
       delete_circle:
       ;;;
        finit
       fld dword[a] ;a
       fsub dword[five]
       fist dword[temp]
       mov cx , [temp] 
       ;
       fadd dword[five]
       fadd dword[five]
       fistp dword[temp]
       mov si,[temp]
       circle1:
       cmp cx , si
       jg end_circle1
       
       mov [temp] , cx
       fild dword [temp]
       fsub dword [a]
       fmul st0
       fsub dword [radius]
       fchs
       fsqrt
       fadd dword [b]
       fistp dword [temp]
       mov dx , [temp]
       mov al , 0b
       mov ah , 0ch
       int 10h
       ;
       ;
       fld dword[b] ; b
       fadd dword[b]; 2*b
       fistp dword[temp]
       mov di,[temp]
       ;
       mov bx , dx
       sub dx , di
       neg dx
       fill_loop1:
       cmp dx , bx
       jg end_fill_loop1
       inc dx
       mov al , 0b
       mov ah , 0ch
       int 10h
       jmp fill_loop1
       end_fill_loop1:
       inc cx
       jmp circle1
       end_circle1:
       ;;;;;;
       ret
       
       ;THE THETA FUNCTION : [theta reflection (a,b)]
       ;;;;;;;;;;;;
            reflection:
            fld dword[theta]
            fchs
            fstp dword[theta]
            call find_B
       ret
       
       
       ;FIND THE CONSTANT B (IN y=mx+B) [B find_B(a,b,theta)]:
       find_B:
       fld dword[theta]
       fmul dword[conversion] ; in radians
       fptan
       fmul
       ; st0=tan (theta)
       fmul dword[a]
       fsub dword[b]
       fchs
       fstp dword[B]
       ret
       ;GO LEFT FUNCTION: [void go_left(tehta,B)]
            
       go_left:   
       xor ecx,ecx
       mov cx,256
       drawing_loop:
       cmp cx,0
       jle leave_left
       ;
       ;
       cmp cx,20
       jg left_boundry_not_reached
       ; left boundry reached:
       call hit_or_miss ; di = 0/1... miss/hit
       cmp di,0
       je left_boundry_not_reached
       ; the ball hit the pad:
       jmp leave_left   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; might be wrong BITCH
       ;
       ;
       left_boundry_not_reached:
       call check_input ; ax=0/1/2  ... maf / down / up
       cmp ax,0 ;maf
       je dont_move_pad
       cmp ax,1 ; down
       je move_pad_down_label
       cmp ax,2 ; up
       ; move_pad_up
       pushad
       call move_pad_up
       popad
       jmp dont_move_pad
       ;
       move_pad_down_label:
       pushad
       call move_pad_down
       popad
       dont_move_pad:
       pushad
       call check_U_L_boundry ; ax=0/1/2/3
       and ax,010b
       popad
       jnz call_reflection ; case2 or 3
       ;else .. continue
       jmp continue
       call_reflection:
       pushad
       call reflection
       popad
       
       ;
       continue:
       ;finding m = tan theta
       fld dword[theta]
       fmul dword[conversion] ; in radians
       fptan
       fmul
       ; st0=tan (theta)
       ;
       mov [a],ecx 
       fild dword[a]
       fst dword[a]
       fmul ; i*m
       fadd dword[B]
       fstp dword[b]
       ;st0=y=m*i+b
       pushad
       call draw_circle
       call delay
       call delete_circle
       popad
       dec cx
       jmp drawing_loop
       leave_left:
       ret
       ;CHECK BALL BOUNDRY [double_boolean check_boundry(a,b)] le al 3 walls
        check_U_L_boundry: 
       fld dword[b]
       fist dword[b]
       mov bx,[b]
       cmp bx,5
       ;
       fstp dword[b]
       ;
       jle reached_upper_boundry
       cmp bx,195
       jge reached_lower_boundry
       ;if no boundry is reached:
       mov ax,0
       ret
       reached_upper_boundry:
       mov ax,2
       ret
       reached_lower_boundry:
       mov ax,3
       ret
       
        ;BALL TOUCHED THE PAD? [boolean hit_or_miss(b,p)]: 0/1 ...... miss/hit
       hit_or_miss:
       fld dword  [b] ; st0=100.0
       fist dword [b] ; b=100
       mov ax,[b]     ; ax= b=100
       fstp dword [b] ; b=100.0
       add ax,5 ; al s67 al t7t le alkoora
       mov bx,[p] ; al 6rf al foo8 le al pad
       cmp ax,bx
       jl miss
       ; ax>bx
       sub ax,10 ; al s67 al foo8 le al koora
       add bx,25 ; al s67 al t7t le al pad
       cmp ax,bx
       jg miss
       ; hit:
       mov di,1
       ret
       miss:
       mov di,0
       ret
       
       ;THE DELAY FUNCTION:
       delay:
       mov bp , 100
       mov si , 100
       delay3:
       dec bp
       nop
       jnz delay3
       dec si
       cmp si , 0
       jnz delay3
       ret
       
       return:
       



	 ;section .data:
      radius: dd 25.0
      five: dd 5.0
      a: dd 256.0
      b: dd 100.0
      temp: dd 0
      theta: dd 30.0
      conversion:dd 0.0174533
      B: dd 0.0
      p: dd 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times (0x400000 - 512) db 0

db 	0x63, 0x6F, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x78, 0x00, 0x00, 0x00, 0x02
db	0x00, 0x01, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
db	0x20, 0x72, 0x5D, 0x33, 0x76, 0x62, 0x6F, 0x78, 0x00, 0x05, 0x00, 0x00
db	0x57, 0x69, 0x32, 0x6B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x78, 0x04, 0x11
db	0x00, 0x00, 0x00, 0x02, 0xFF, 0xFF, 0xE6, 0xB9, 0x49, 0x44, 0x4E, 0x1C
db	0x50, 0xC9, 0xBD, 0x45, 0x83, 0xC5, 0xCE, 0xC1, 0xB7, 0x2A, 0xE0, 0xF2
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
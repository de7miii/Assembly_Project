bits 16
org 0x7C00

cli

mov ah , 0x02
mov al ,8
mov dl , 0x80
mov ch , 0
mov dh , 0
mov cl , 2
mov bx, code_starts_here
int 0x13
jmp code_starts_here


times (510 - ($ - $$)) db 0
db 0x55, 0xAA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
code_starts_here:
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
        ;intro
        mov byte[delay_time],5
        call transtion3
        call write_options
        ;
        ;options
        ;call choose_mode ; ax =1/2 .... up / down   ... 1 player / 2 players
         ;restore all memory values:
         
         ;
        cmp ax,2
        jmp two_players_mode;je two_players_mode
        cmp ax,1
        je one_players_mode
        ;
        one_players_mode:
        mov byte[color],15
        call transtion2
        ;game starts at one player mode
        call draw_pad
        call draw_right_pad
        call draw_right_boundary
        main_loop1:
        call go_left
        cmp ax , 0
        je call_you_lost1
        ;call go_right_at_1_player_mode
        cmp ax,2
        je call_you_lost1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        jmp main_loop1
        call_you_lost1:
        ;
        call outro
        ;
        ;call credit
        
        ret
        two_players_mode:
        call transtion2
        mov byte[color],15
        mov byte[rp],150
        mov byte[p],150
        mov byte[delay_time],150
        
        ;game starts at two players mode
        call draw_pad
        call draw_right_pad
        call draw_right_boundary
        main_loop:
        call go_left
        cmp ax , 0
        ;je call_you_lost
        call go_right
        cmp ax,2
        ;je call_you_lost ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        jmp main_loop
        call_you_lost:
        ;
        call outro
        ;
        ;call credit
      
      
      
      
      
      
      
      

      
      
      jmp return
      ;THE FUNCTIONS:
      ;PRINT THE OPTIONS IN THEIR LOCATIONS [void write_options()]
      write_options:
      mov dh ,  5 ; 25 rows
      mov dl,  14 ; 40 coulomns
      mov bh, 0  ; page number
      mov ah, 2  ; function to set cursor posotion at : row dh , column dx 
      int 10h 
      mov esi , the_options
      mov ah , 14 ; function to print character at cursor posotion 
      mov byte [color] , 14 ; color of character
      print_options:
      lodsb
      cmp  al , 0
      je end_print_options
      cmp al  , 10
      je next_option
      int 10h
      jmp print_options
      next_option:
      inc dh
      inc dh
      mov dl , 14
      mov ah ,2
      int 10h
      mov ah , 14
      jmp print_options
      the_options: db '1.One Player(D)',10,'2.Two Player(U)',0
      end_print_options:
      ret
      
      ;CHOOSE MODES BETWEEN MULTIPLAYER AND ONE PLAYER [boolean choose_mode(user input)]:
      choose_mode:
      checking_user_input:
      call check_input
      cmp ax,1
      je end_checking_user_input
      cmp ax,2
      je end_checking_user_input
      jmp checking_user_input
      
      end_checking_user_input:
      
      ret
      
      ;DELETES EVERYTHING EXCEPT THE WINING PAD [void transtion4()]
      transtion4:
      mov byte[color],0 ;black
      mov al,[color]
      mov ah , 0Ch
      ;
      xor ecx,ecx
      x_axis:
      call delay
      cmp cx,320
      jge done_drawing
      xor edx,edx
      y_axis:
      cmp dx,200
      jge y_axis_done
      ; else
      ;
      cmp cx,130
      jl cont
      ; cx is more than 157
      cmp cx,133
      jg cont
      ;     157<cx<163  :
      cmp dx , 85
      jl cont
      ; dx is more than 90
      cmp dx,120
      jg cont
      ;    90<dx<10  :
      inc dx
      jmp y_axis
      ;
      cont:
      int 10h
      inc dx
      jmp y_axis
      y_axis_done:
      inc cx
      jmp x_axis
      done_drawing:
      ret
      
      ;OUTRO [void outro(1/2)]  ax=1-->blue wins/ax=2--> red wins
      outro:
      cmp ax,0
      je red_wins
      ;blue wins:
      mov byte[color],1
      mov byte[delay_time],70
      call transtion
      call transtion4
      ret
      red_wins:
      mov byte[color],4
      mov byte[delay_time],70
      call transtion
      call transtion4
      ret
      
      ;CIRCLE WITH CUSTOM RADIUS [void draw_intro_circle(radius)] :
      draw_intro_circle:
      pushad
      ;;;;;;;;;;;;;;;;;;;;;;;;;;	
       finit
       fld dword[intro_a] ;a
       fsub dword[intro_radius]
       fist dword[temp]
       mov cx , [temp] 
       ;
       fadd dword[intro_radius]
       fadd dword[intro_radius]
       fistp dword[temp]
       mov si,[temp]
       ;
       fld dword[intro_radius]
       fmul st0
       fstp dword[intro_radius]
       ;
       intro_circle:
       cmp cx , si
       jg end_intro_circle
       
       mov [temp] , cx
       fild dword [temp]
       fsub dword [intro_a]
       fmul st0
       fsub dword [intro_radius]
       fchs
       fsqrt
       fadd dword [intro_b]
       fistp dword [temp]
       mov dx , [temp]
       mov al , [color]
       mov ah , 0ch
       int 10h
       ;
       ;
       fld dword[intro_b] ; b
       fadd dword[intro_b]; 2*b
       fistp dword[temp]
       mov di,[temp]
       ;
       ;;;;;;;;;;;;;;;;;
        ;
       mov bx , dx
       sub dx , di
       neg dx
       intro_fill_loop:
       cmp dx , bx
       jg end_intro_fill_loop
       inc dx
       mov al , [color]
       mov ah , 0ch
       int 10h
       jmp intro_fill_loop
       end_intro_fill_loop:
      
       ;;;;;;;;;;;;;;
       inc cx
       jmp intro_circle
       end_intro_circle:
       ;
       fld dword[intro_radius]
       fsqrt
       fstp dword[intro_radius]
       
      ;;;;;;;;;;;;;;;;;;;;;;;;;;
      popad
      ret
            
      ;MAKING THE CIRCLES LOOK ALIVE [ void circle_beat(radius)] :
      circle_beat:
      
      beat:
      xor di,di
      mov ax,20
      mov bx,10
      mov cx,1
      size_up:
      cmp di,5
      jge end_size_up
      mov [intro_radius],ax
      fild dword[intro_radius]
      fstp dword[intro_radius]
      mov byte[color],7
      call draw_intro_circle
      fldz
      fstp dword [intro_radius]
      ;;;
      mov [intro_radius],bx
      fild dword[intro_radius]
      fstp dword[intro_radius]
      mov byte[color],15
      call draw_intro_circle
      fldz
      fstp dword [intro_radius]
      ;;;;
      mov [intro_radius],cx
      fild dword[intro_radius]
      fstp dword[intro_radius]
      mov byte[color],4
      call draw_intro_circle
      fldz
      fstp dword [intro_radius]
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       call delay
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;;
      inc di
      add ax,di
      add bx,di
      add cx,di
      pushad
      call check_input
      cmp ax,1
      popad
      je end_intro
      jmp size_up
      end_size_up:
      
      
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      
    mov di,1
      size_down:
      cmp di,5
      jge end_size_down
      mov [intro_radius],ax
      fild dword[intro_radius]
      fstp dword[intro_radius]
      mov byte[color],7
      call draw_intro_circle
      fldz
      fstp dword [intro_radius]
      ;;;
      mov [intro_radius],bx
      fild dword[intro_radius]
      fstp dword[intro_radius]
      mov byte[color],15
      call draw_intro_circle
      fldz
      fstp dword [intro_radius]
      ;;;;
      mov [intro_radius],cx
      fild dword[intro_radius]
      fstp dword[intro_radius]
      mov byte[color],4
      call draw_intro_circle
      fldz
      fstp dword [intro_radius]
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       call delay
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      mov [intro_radius],ax
      fild dword[intro_radius]
      fstp dword[intro_radius]
      mov byte[color],0
      call draw_intro_circle
      fldz
      fstp dword [intro_radius]
      ;
            mov [intro_radius],bx
      fild dword[intro_radius]
      fstp dword[intro_radius]
      mov byte[color],0
      call draw_intro_circle
      fldz
      fstp dword [intro_radius]
      ;
            mov [intro_radius],cx
      fild dword[intro_radius]
      fstp dword[intro_radius]
      mov byte[color],0
      call draw_intro_circle
      fldz
      fstp dword [intro_radius]
      ;;;
      inc di
      sub ax,di
      sub bx,di
      sub cx,di
       pushad
      call check_input
      cmp ax,1
      popad
      je end_intro
     
      jmp size_down
      end_size_down:
      jmp beat
      end_intro:
      ret
      
      ;CHECKING USER INPUT [boolean check_input ()] :
      check_input:
        ; checking right and left break codes
       call check_L_R_break_code
      ; d5l 7aga
      in al,0x60 ; user input
      cmp al,0x48
      je mov_pad_down
      cmp al,0x50
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
      
     ;CHECKING RIGHT USER INPUT [boolean check_right_input ()] :
      check_right_input:
        ; checking right and left break codes
       call check_L_R_break_code
      in al,0x60 ; user input
      cmp al,0x10
      je mov_right_pad_down
      cmp al,0x1E
      je mov_right_pad_up
      ; no valid input
      no_valid_right_input:
      mov ax,0
      ret
      mov_right_pad_down:
      mov ax,1
      ret
      mov_right_pad_up:
      mov ax,2
      ret
      
      ;CHANGING THE ANGLE AFTER HITTING THE PAD [theta modified_theta(b,p,theta)]:
      modified_theta:
      ;
      ;jmp acceptable
      fld dword [theta]
      fistp dword[theta]
      mov bx,[theta] ; bx = theta
      cmp bx , 0
      jl negative_theta
      cmp bx  , 60
      jle acceptable
      ;decremt theta by 6
      sub bx , 6
      mov [theta] , bx
      fild dword [theta]
      fstp dword [theta]
      ret
      negative_theta:
      cmp bx  , -60
      jge acceptable
      ;decremt theta by 6
      add bx , 6
      mov [theta] , bx
      fild dword [theta]
      fstp dword [theta]
      ret
      ;
      acceptable:
      fild dword [theta]
      fstp dword [theta]
      fld dword [b]
      fist dword[b]
      mov bx,[b]
      fstp dword [b]
      mov ax,[p]
      ;
      sub bx,ax
      cmp bx,5  ;b-p
      jle sub_theta_max
      cmp bx,10
      jle sub_theta_min
      cmp bx,15
      jle dont_change_theta
      cmp bx,20
      jle add_theta_min
      cmp bx,25
      jle add_theta_max
      sub_theta_max:
      fld dword [theta]
      fsub dword[max]
      fstp dword[theta]
      ret
      ;
      sub_theta_min:
      fld dword [theta]
      fsub dword[min]
      fstp dword[theta]
      ret
      ;
      dont_change_theta:
      
      ret
      add_theta_min:
      fld dword [theta]
      fadd dword[min]
      fstp dword[theta]
      ret
      ;
      add_theta_max:
      fld dword [theta]
      fadd dword[max]
      fstp dword[theta]
      ret
     
      ;;;;;;;;;;;;;;;;;;;;;
         ;CHANGING THE ANGLE AFTER HITTING THE RIGHT PAD [theta modified_thetar(b,rp,theta)]:
      modified_thetar:
      ;
      ;jmp acceptable
      fld dword [theta]
      fistp dword[theta]
      mov bx,[theta] ; bx = theta
      cmp bx , 0
      jl negative_thetar
      cmp bx  , 60
      jle acceptabler
      ;decremt theta by 6
      sub bx , 6
      mov [theta] , bx
      fild dword [theta]
      fstp dword [theta]
      ret
      negative_thetar:
      cmp bx  , -60
      jge acceptabler
      ;decremt theta by 6
      add bx , 6
      mov [theta] , bx
      fild dword [theta]
      fstp dword [theta]
      ret
      ;
      acceptabler:
      fild dword [theta]
      fstp dword [theta]
      fld dword [b]
      fist dword[b]
      mov bx,[b]
      fstp dword [b]
      mov ax,[rp]
      ;
      sub bx,ax
      cmp bx,5  ;b-p
      jle sub_theta_maxr
      cmp bx,10
      jle sub_theta_minr
      cmp bx,15
      jle dont_change_thetar
      cmp bx,20
      jle add_theta_minr
      cmp bx,25
      jle add_theta_maxr
      sub_theta_maxr:
      fld dword [theta]
      fadd dword[max]
      fstp dword[theta]
      ret
      ;
      sub_theta_minr:
      fld dword [theta]
      fadd dword[min]
      fstp dword[theta]
      ret
      ;
      dont_change_thetar:

      ret
      add_theta_minr:
      fld dword [theta]
      fsub dword[min]
      fstp dword[theta]
      ret
      ;
      add_theta_maxr:
      fld dword [theta]
      fsub dword[max]
      fstp dword[theta]
      ret
     
      
      ;
      ;CHECKING BREAK LEFT AND RIGHT BREAK CODES AND ACTIONG UPON THEM [void check_L/R_break_code()]:
      check_L_R_break_code:
      call check_left_break_code ; ax =0/1/2
       cmp ax,0
       je second_check2
       cmp ax,1 ; Q_break_code
       je clear_left_moving_up2
       cmp ax,2 ;A_break_code
       ;
       mov byte[left_moving_down],0
       jmp second_check2
       clear_left_moving_up2:
       mov byte[left_moving_up],0
       
       second_check2:
      call check_right_break_code ; ax=0/1/2
       
       cmp ax,0
       je continue_the_code2
       cmp ax,1 ; up_break_code
       je clear_right_moving_up2
       cmp ax,2 ;down_break_code
       ;
       mov byte[right_moving_down],0
       jmp continue_the_code2
       
       clear_right_moving_up2:
       mov byte[right_moving_up],0
       
       continue_the_code2:
      ret
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;GO RIGHT FUNCTION [void go_right(a,b,theta)]:
      go_right:
      ;;;;; change the angle as desired
      call modified_theta
      ;
       call reflection
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       xor ecx,ecx
       mov cx,20
       drawing_loop2:
       cmp cx,[right_B]
       jge leave_right
       ;
       ;
       cmp cx,240
       jle right_boundry_not_reached
       ; right boundry reached:
       call right_hit_or_miss ; di = 0/1... miss/hit
       cmp di,0
       je right_boundry_not_reached
       ; the ball hit the pad:
       mov ax,1 ; call go right
       ret
       ;
       ;
       right_boundry_not_reached:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ; checking right and left break codes
       call check_L_R_break_code
       ;check variables
       cmp byte[right_moving_up],1
       je move_right_pad_up_label2
       cmp byte[right_moving_down],1
       je move_right_pad_down_label2
         ;check right input
         call check_input
         cmp ax,0
         je dont_move_right_pad2
         cmp ax,1
         je move_right_pad_up_label2
         cmp ax,2
         je move_right_pad_down_label2
         ;
         
         ; move right pad
        move_right_pad_up_label2:
        pushad
        call move_right_pad_up
        mov byte[right_moving_up],1
        popad
        jmp dont_move_right_pad2
        ;
        move_right_pad_down_label2:
        pushad
        call move_right_pad_down
        mov byte[right_moving_down],1
        popad
        ;
        dont_move_right_pad2:
       ; checking right and left break codes
       call check_L_R_break_code
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;check left variables
       cmp byte[left_moving_up],1
       je move_left_pad_up_label2
       cmp byte[left_moving_down],1
       je move_left_pad_down_label2
         ;check left input
         call check_right_input
         cmp ax,0
         je dont_move_left_pad2
         cmp ax,1
         je move_left_pad_up_label2
         cmp ax,2
         je move_left_pad_down_label2
         ;
         
         ; move left pad
        move_left_pad_up_label2:
        pushad
        call move_pad_up
        mov byte[left_moving_up],1
        popad
        jmp dont_move_left_pad2
        ;
        move_left_pad_down_label2:
        pushad
        call move_pad_down
        mov byte[left_moving_down],1
        popad
        ;
        dont_move_left_pad2:
       ; checking right and left break codes
       call check_L_R_break_code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       pushad
       call check_U_L_boundry ; ax=0/1/2/3
       and ax,010b
       popad
       jnz call_reflection2 ; case2 or 3
       ;else .. continue
       jmp continue2
       call_reflection2:
       pushad
       call reflection
       popad
       
       ;
       continue2:
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
       mov al , [color]
       pushad
       mov byte [color] ,4
       call draw_circle
       call delay
       call delete_circle 
       popad
       mov [color], al
       inc cx
       
       
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;
       pushad
       mov cx , [start_point_x]
       mov dx , [start_point_y]
       mov al , [color]
       mov ah , 0Ch
       int 10h
;       
       cmp cx , 319
       jge next_line1
       add cx,2
       jmp set_memory1
       next_line1:
       
       add al , 2
       cmp dx , 200
       jge reset_memory1
       inc dx
       mov cx , 263
       jmp set_memory1
       reset_memory1:
       mov cx , 263
       mov dx , 0
       
       set_memory1:
       mov [start_point_x] , cx
       mov [start_point_y] , dx
       mov [color] , al
       popad
;       ;
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
       
       jmp drawing_loop2
       leave_right:
       mov ax,2 ; youu lost :(
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ret
      
      ;COUNT THE SCORE:[int score()]:
      score:
      
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
        ;MOVING THE RIGHT PAD UPWARDS [void move_right_pad_up(rp)]
      move_right_pad_up:
      call right_pad_boundry
      cmp ax,2 ; reached upper boundry
      je cant_move_up_r
      call delete_right_pad
      ;
      mov cx,[rp]
      sub cx,5
      mov [rp] ,cx
      ;
      call draw_right_pad
      cant_move_up_r:
      ret
      
      ;MOVING THE RIGHT PAD DOWNWARDS [void move_right_pad_down(rp)]
      move_right_pad_down:
      call right_pad_boundry
      cmp ax,1 ; reached lower boundry
      je cant_move_down_r
      call delete_right_pad
      ;
      mov cx,[rp]
      add cx,5
      mov [rp] ,cx
      ;
      call draw_right_pad
      cant_move_down_r:
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
      
      ;CHECKING RIGHT PAD'S BOUNDRIES : [boolean right_pad_boundry(rp)]
      right_pad_boundry:
      mov cx,[rp]
      mov bx,200
      sub bx,25  ;200-25
      cmp cx,0
      jle upper_right_pad_boundry
      cmp cx,bx
      jge lower_right_pad_boundry
      ; no boundry reached
      mov ax,0
      ret
      lower_right_pad_boundry:
      mov ax,1
      ret
      upper_right_pad_boundry:
      mov ax,2
      ret
      
      ;DRAW PAD ON THE LEFT [void draw_pad (p)]
      draw_pad:
      mov dx , [p]
      mov cx , 14 
      mov bx , 25
      add bx , dx ; p + 25
      pad_draw_loop:
      cmp dx , bx
      jge end_pad_draw_loop
      
      
       mov al , 1
       mov ah , 0ch
       int 10h
      
      inc dx
      jmp pad_draw_loop
      end_pad_draw_loop: 
      ret
      
      ;DELETE PAD FROM THE LEFT [void delete_pad (p)]
      delete_pad:
      mov dx , [p]
      mov cx , 14 
      mov bx , 25
      add bx , dx ; p + 25
      pad_delete_loop:
      cmp dx , bx
      jge end_pad_delete_loop
      
      
       mov al , 15
       mov ah , 0ch
       int 10h
      
      inc dx
      jmp pad_delete_loop
      end_pad_delete_loop: 
      ret
      
      ;DRAW PAD ON THE RIGHT [void draw_right_pad (rp)]
      draw_right_pad:
      mov dx , [rp]
      mov cx , 246 
      mov bx , 25
      add bx , dx ; rp + 25
      pad_draw_right_loop:
      cmp dx , bx
      jge end_pad_draw_right_loop
      
      
       mov al , 4
       mov ah , 0ch
       int 10h
      
      inc dx
      jmp pad_draw_right_loop
      end_pad_draw_right_loop: 
      ret
      
      ;DELETE PAD FROM THE RIGHT [void delete_right_pad (rp)]
      delete_right_pad:
      mov dx , [rp]
      mov cx , 246 
      mov bx , 25
      add bx , dx ; rp + 25
      pad_delete_right_loop:
      cmp dx , bx
      jge end_pad_delete_right_loop
      
      
       mov al , 15
       mov ah , 0ch
       int 10h
      
      inc dx
      jmp pad_delete_right_loop
      end_pad_delete_right_loop: 
      ret
      
      
      
      ;DRAWING A CIRCLE AT (a,b): [void draw_circle(a,b , color)]
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
       mov al , [color]
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
       mov al , [color]
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
       mov al , 15
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
       mov al , 15
       mov ah , 0ch
       int 10h
       jmp fill_loop1
       end_fill_loop1:
       inc cx
       jmp circle1
       end_circle1:
       ;;;;;;
       ret
       
       ;DRAW THE LINE SHOWING THE RIGHT BOUNDARY[void draw_right_boundary()]
       draw_right_boundary:
       mov cx,262
       xor dx,dx
       draw_right_boundary_loop:
       cmp dx,200
       jge end_draw_right_boundary_loop
       mov al,0x51
       mov ah,0ch
       int 10h
       inc dx
       jmp draw_right_boundary_loop
       end_draw_right_boundary_loop:
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
       ;GO LEFT FUNCTION: [boolean go_left(tehta,B)] 0,1 .... call you lost / call go right
            
       go_left:
       ;;;;; change the angle as desired
      call modified_thetar
      ;
      
       call reflection   
       xor ecx,ecx
       mov cx,240
       drawing_loop:
       cmp cx,[left_B]
       jle leave_left
       ;
              ;
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
       ;
       cmp cx,20
       jg left_boundry_not_reached
       ; left boundry reached:
       call hit_or_miss ; di = 0/1... miss/hit
       cmp di,0
       je left_boundry_not_reached
       ; the ball hit the pad:
       mov ax,1 ; call go right
       ret
       ;
       ;
       left_boundry_not_reached:
       
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ; checking right and left break codes
       call check_L_R_break_code
       ;check variables
       cmp byte[right_moving_up],1
       je move_right_pad_up_label
       cmp byte[right_moving_down],1
       je move_right_pad_down_label
         ;check right input
         call check_input
         cmp ax,0
         je dont_move_right_pad
         cmp ax,1
         je move_right_pad_up_label
         cmp ax,2
         je move_right_pad_down_label
         ;
         
         ; move right pad
        move_right_pad_up_label:
        pushad
        call move_right_pad_up
        mov byte[right_moving_up],1
        popad
        jmp dont_move_right_pad
        ;
        move_right_pad_down_label:
        pushad
        call move_right_pad_down
        mov byte[right_moving_down],1
        popad
        ;
        dont_move_right_pad:
       ; checking right and left break codes
       call check_L_R_break_code
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;check left variables
       cmp byte[left_moving_up],1
       je move_left_pad_up_label
       cmp byte[left_moving_down],1
       je move_left_pad_down_label
         ;check left input
         call check_right_input
         cmp ax,0
         je dont_move_left_pad
         cmp ax,1
         je move_left_pad_up_label
         cmp ax,2
         je move_left_pad_down_label
         ;
         
         ; move left pad
        move_left_pad_up_label:
        pushad
        call move_pad_up
        mov byte[left_moving_up],1
        popad
        jmp dont_move_left_pad
        ;
        move_left_pad_down_label:
        pushad
        call move_pad_down
        mov byte[left_moving_down],1
        popad
        ;
        dont_move_left_pad:
        ; checking right and left break codes
       call check_L_R_break_code
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
       mov al , [color]
       pushad
       mov byte [color] , 1
       call draw_circle
       call delay
       call delete_circle 
       popad
       mov [color], al
      
       dec cx
       
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;
       pushad
       mov cx , [start_point_x]
       mov dx , [start_point_y]
       mov al , [color]
       mov ah , 0Ch
       int 10h
       
       cmp cx , 319
       jge next_line
       add cx ,2
       jmp set_memory
       next_line:
       
       add al , 2
       cmp dx , 200
       jge reset_memory
       inc dx
       mov cx , 263
       jmp set_memory
       reset_memory:
       mov cx , 263
       mov dx , 0
       set_memory:
       mov [start_point_x] , cx
       mov [start_point_y] , dx
       mov [color] , al
       popad
       ;
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       jmp drawing_loop
       leave_left:
       mov ax,0 ; youu lost :(
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
       ; CHECKING THE LEFT BREAK CODE [boolean check_left_break_code() ]: 0/1/2 ... nothing/A/Q
       check_left_break_code:
      in al,0x60 ; user input
      cmp al,0x90
      je Q_break_code
      cmp al,0x9E
      je A_break_code
      ; no valid input
      no_left_break_code:
      mov ax,0
      ret
      Q_break_code:
      mov ax,1
      ret
      A_break_code:
      mov ax,2
       ret
       ; CHECKING THE RIGHT BREAK CODE [boolean check_right_break_code() ]: 0/1/2 ... nothing/up/down
       check_right_break_code:
      in al,0x60 ; user input
      cmp al,0xC8
      je up_break_code
      cmp al,0xD0
      je down_break_code
      ; no valid input
      no_right_break_code:
      mov ax,0
      ret
     up_break_code:
      mov ax,1
      ret
      down_break_code:
      mov ax,2
       ret
       
        ;BALL TOUCHED THE RIGHT PAD? [boolean right_hit_or_miss(b,rp)]: 0/1 ...... miss/hit
       right_hit_or_miss:
       fld dword  [b] ; st0=100.0
       fist dword [b] ; b=100
       mov ax,[b]     ; ax= b=100
       fstp dword [b] ; b=100.0
       add ax,5 ; al s67 al t7t le alkoora
       mov bx,[rp] ; al 6rf al foo8 le al pad
       cmp ax,bx
       jl miss2
       ; ax>bx
       sub ax,10 ; al s67 al foo8 le al koora
       add bx,25 ; al s67 al t7t le al pad
       cmp ax,bx
       jg miss2
       ; hit:
       mov di,1
       ret
       miss2:
       mov di,0
       ret
       ; TRANSTION SCREEN BEFORE THE GAMES BEGINS [void transtion()]
       transtion:
       xor ecx , ecx
       horizontal:
       cmp cx , 320
       jge end_horizontal
       call delay
       xor edx , edx
       vertical:
       cmp dx , 200
       jge end_vertical
       mov al , [color]
       mov ah , 0Ch
       int 10h
       inc dx
       jmp vertical
       end_vertical:
       inc cx
       jmp horizontal
       end_horizontal:
       
       ret
       
       ; TRANSTION2 SCREEN BEFORE THE GAMES BEGINS [void transtion2()]
       transtion2:
       xor ecx , ecx
       horizontal2:
       cmp cx , 161
       jge end_horizontal2
       xor edx , edx
       call delay
       vertical2:
       cmp dx , 200
       jge end_vertical2
       mov al , 15
       mov ah , 0Ch
       int 10h
       inc dx
       jmp vertical2
       end_vertical2:
       sub cx ,320
       neg cx
       xor edx , edx
       white_from_right:
       cmp dx , 200
       jge end_white_from_right
       mov al , 15
       mov ah , 0Ch
       int 10h
       inc dx
       jmp white_from_right
       end_white_from_right:
       neg cx
       add cx , 320
       
       inc cx
       jmp horizontal2
       end_horizontal2:
       
       ret
       
       
       ; TRANSTION3 SCREEN BEFORE THE GAMES BEGINS [void transtion3()]
       transtion3:
       ;draw first block
       mov byte[color] , 14
       mov dword [start_point_x] , 5
       mov dword [start_point_y] , 5
       mov dword [right_end]     , 105
       mov dword [bottom_end]    , 65
       call animiation
       ;draw 2 block
       mov byte[color] , 14
       mov dword [start_point_x] , 110
       mov dword [start_point_y] , 130
       mov dword [right_end]     , 230
       mov dword [bottom_end]    , 160
       call animiation
       ;draw 3 block
       mov byte[color] , 14
       mov dword [start_point_x] , 290
       mov dword [start_point_y] , 5
       mov dword [right_end]     , 315
       mov dword [bottom_end]    , 65
       call animiation
       ;draw 4 block
       mov byte[color] , 14
       mov dword [start_point_x] , 5
       mov dword [start_point_y] , 70
       mov dword [right_end]     , 105
       mov dword [bottom_end]    , 160
       call animiation
       ;draw 5 block
       mov byte[color] , 14
       mov dword [start_point_x] , 5
       mov dword [start_point_y] , 165
       mov dword [right_end]     , 285
       mov dword [bottom_end]    , 195
       call animiation
       ;draw 6 block
       mov byte[color] , 14
       mov dword [start_point_x] , 110
       mov dword [start_point_y] , 5
       mov dword [right_end]     , 230
       mov dword [bottom_end]    , 125
       call animiation
       ;draw 7 block
       mov byte[color] , 14
       mov dword [start_point_x] , 290
       mov dword [start_point_y] , 70
       mov dword [right_end]     , 315
       mov dword [bottom_end]    , 195
       call animiation
       ;draw 8 block
       mov byte[color] , 14
       mov dword [start_point_x] , 235
       mov dword [start_point_y] , 5
       mov dword [right_end]     , 285
       mov dword [bottom_end]    , 160
       call animiation
       ;
       mov byte[delay_time],70
       call delay
       ;DELETING 6 BLOCK TO WRITE OPTIONS:
       mov byte[color] , 0
       mov dword [start_point_x] , 110
       mov dword [start_point_y] , 5
       mov dword [right_end]     , 230
       mov dword [bottom_end]    , 125
       call animiation
       ret
       
       
      ; WHEN THE GAME ENDS ROLL CREDIT [void credit()]:
      credit:
      mov bl , [color]
      xor ecx , ecx
      roll_down:
      cmp ecx , 25 
      jg end_roll_down
      mov [mid] , ecx
      mov byte[color] , 14
      call write_names
      call delay
      call delay
      call delay
      call delay
      call delay
      call delay
      mov byte[color] , 0
      call write_names
      inc ecx 
      jmp roll_down
      end_roll_down:
              
      ret
      ;
      ;WRITE LIST OF NAMES IN MIDDLE OF SCREEN (void write_names(mid , color))
      write_names:
      mov dh , [mid] ; 25 rows
      mov dl, 15 ; 40 coulomns
      mov bh, 0  ; page number
      mov ah, 2  ; function to set cursor posotion at : row dh , column dx 
      int 10h 
      mov esi , names
      mov ah , 14 ; function to print character at cursor posotion 
      mov bl , [color] ; color of character
      print_names:
      lodsb
      pushad
      popad
      cmp  al , 0
      je end_print_names
      cmp al  , 10
      je new_line
      int 10h
      jmp print_names
      new_line:
      cmp dh , 24
      jge end_print_names
      inc dh
      inc dh
      mov dl , 15
      mov ah ,2
      int 10h
      mov ah , 14
      jmp print_names
      names: db ' 7elmi',10,' Abdualrahman',10," Ammar" ,10, ' Kahlid',10, ' Kahlid',0
      end_print_names:
      ret
      
       
       
       ;DRAW RECTANGULERS AT SPCEFIC LOCATIONS AND COLORS [void animiation (start_point_x , start_point_y , right_end , bottom_end  , color)]
       animiation:
       mov cx , [start_point_x]
       mov dx , [start_point_y]
       mov di , [right_end]
       mov bx , [bottom_end]
       mov al , [color]
       x:
       cmp cx , di
       jge end_x
       mov dx ,[start_point_y]
       call delay
       y:
       cmp dx , bx
       jge end_y 
       mov ah , 0Ch
       int 10h
       ;call delay
       inc dx
       jmp y
       end_y:
       inc cx
       jmp x
       end_x:
       call delay
       ret
       
       
       ;THE DELAY FUNCTION [void delay(delay_time)]:
       delay:
       mov bp , [delay_time]
       mov si , [delay_time]
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
      right_moving_up: dd 0
      right_moving_down:dd 0
      left_moving_up: dd 0
      left_moving_down: dd 0
      intro_radius: dd 0.0
      intro_a: dd 220.0
      intro_b: dd 50.0
      left_B: dd 0
      right_B: dd 256
      theta: dd 30.0
      start_point_x: dd 263
      start_point_y: dd 0
      right_end: dd 100
      bottom_end: dd 100 
      color: dd 51
      delay_time: dd 33
      radius: dd 25.0
      five: dd 5.0
      a: dd 239.0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      b: dd 163.0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      temp: dd 0
      conversion:dd 0.0174533
      B: dd 0.0
      p: dd 150
      rp: dd 150
      mid: dd 0
      min: dd 3.0
      max: dd 6.0
      our_names: db 'AQMQMQAQRQ'
      times(150) db 0
      db 'KQHQAQLQIQDQz' , 
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
data segment
    main1 db "ROBOT Rescue"
    main2 db "Hay thu thap du 4 chu cai theo thu tu sau:" ; 42
    main3 db "'O' -> 'B' -> 'O' -> 'T'"              ; 24
    main4 db "Di chuyen bang A,W,S,D"                ; 22
    main5 db "W: LEN"                                ; 6
    main6 db "S: XUONG"                              ; 8
    main7 db "D: PHAI"                               ; 7
    main8 db "A: TRAI"                               ; 7
    main9 db "Chuc ban may man !!!"                  ; 20
    main10 db "Press any key to start..."

    ; THANH MAU
    hlths db "Lives:",3,3,3  

    ; DIA CHI CAC CHU CAI TREN MAN HINH
    letadd dw 09b4h,0848h,06b0h,01E8h,4 Dup(0)

    ; DIA CHI MAC DINH (DUNG DE RESET CHU CAI)
    dletadd dw 09b4h,0848h,06b0h,01E8h,4 Dup(0)

    ; SO CHU CAI CAN AN (DUNG LAM MAC DINH)
    letnum db 4

    ; SO CHU CAI CON LAI
    fin db 4

    ; GIA TRI THANH MAU
    hlth db 6               

    ; DIA CHI DAU TIEN CUA ROBOT
    sadd dw 07D2h,5 Dup(0)

    ; CHU CAI DAU TIEN TRONG MANG CHU CAI
    snake db 'R',5 Dup(0)

    ; DO DAI CUA RAN
    snakel db 1

    ; KET THUC
    gmwin db "Rescue Complete!"
    gmov db "Mission Failed!"
    endtxt db "Press esc to exit"
ends

stack segment
    dw  128 dup(0)
ends

code segment
start:
    mov ah,1
    int 21h
    mov ax, data
    mov ds, ax

    mov ax,0b800h
    mov es, ax

    cld

    ; AN CON TRO CHUOT
    mov ah,1
    mov ch,2bh
    mov cl,0bh
    int 10h

    call main_menu

startag:
    call bild

    xor cl,cl
    xor dl,dl
read:
    mov ah,1
    int 16h
    jz s1
    mov ah,0
    int 16h
    and al,0dfh
    mov dl,al
    jmp s1

s1:
    cmp dl,1bh
    je ext

left:
    cmp dl,'A'
    jne right
    call ml
    mov cl,dl
    jmp read

right:
    cmp dl,'D'
    jne up
    call mr
    mov cl,dl
    jmp read

up:
    cmp dl,'W'
    jne down
    call mu
    mov cl,dl
    jmp read

down:
    cmp dl,'S'
    jne read1
    call md
    mov cl,dl
    jmp read

read1:
    mov dl,cl
    jmp read

ext:
    xor cx,cx
    mov dh,24
    mov dl,79
    mov bh,0
    mov ax,700h
    int 10h

    mov ah, 4ch
    int 21h
ends

main_menu proc
    call border

    mov di, 224h
    lea si,main1
    mov cx,12
    mov ah,5ah
lopem1:
    mov al,[si]
    stosw
    inc si
    loop lopem1

    mov di, 348h
    lea si,main2
    mov cx,42
    mov ah,0fh
lopem2:
    mov al,[si]
    stosw
    inc si
    loop lopem2

    mov di, 0498h
    lea si,main3
    mov cx,24
    mov ah,0fh
lopem3:
    mov al,[si]
    stosw
    inc si
    loop lopem3

    mov di, 05DAh
    lea si,main4
    mov cx,22
    mov ah,0fh
lopem4:
    mov al,[si]
    stosw
    inc si
    loop lopem4

    mov di, 728h
    lea si,main5
    mov cx,6
    mov ah,0fh
lopem5:
    mov al,[si]
    stosw
    inc si
    loop lopem5

    mov di, 7C8h
    lea si,main6
    mov cx,8
    mov ah,0fh
lopem6:
    mov al,[si]
    stosw
    inc si
    loop lopem6

    mov di,868h
    lea si,main7
    mov cx,7
    mov ah,0fh
lopem7:
    mov al,[si]
    stosw
    inc si
    loop lopem7

    mov di, 908h
    lea si,main8
    mov cx,7
    mov ah,0fh
lopem8:
    mov al,[si]
    stosw
    inc si
    loop lopem8

    mov di, 0A3Ah
    lea si,main9
    mov cx,20
    mov ah,0fh
lopem9:
    mov al,[si]
    stosw
    inc si
    loop lopem9

    mov di, 0B76h
    lea si,main10
    mov cx,25
    mov ah,0fh
lopem10:
    mov al,[si]
    stosw
    inc si
    loop lopem10

    mov ah,7
    int 21h

    call clearall
ret
endp

bild proc
    call border

    lea si,hlths      
    mov di,0          
    mov cx,6          
    mov ah,0ch        
loph_text_display:
    mov al,[si]
    stosw            
    inc si            
    loop loph_text_display

    mov ch,0          
    mov cl,hlth      
    shr cl,1          
    jz bild_no_hearts 

    mov al,3          
loph_hearts_display:
    stosw            
    loop loph_hearts_display
bild_no_hearts:
   
    lea si,main1
    mov di,88h       
    mov cx,12
    mov ah,0bh
loph1:
    mov al,[si]
    stosw
    inc si
    loop loph1

    xor dx,dx
    mov di,sadd
    mov dl,snake

    es: mov word ptr [di],0752h 

    mov ah,0ah
    es: mov word ptr [09b4h],0a4fh ;'O'
    es: mov word ptr [0848h],0a42h ;'B'
    es: mov word ptr [06b0h],0a4fh ;'O'
    es: mov word ptr [01E8h],0a54h ;'T'
ret
endp

ml proc ;move left
    push dx
    call shift_addrs
    sub sadd,2
    call eat
    call move_snake
    pop dx
ret
endp

mr proc ;move right
    push dx
    call shift_addrs
    add sadd,2
    call eat
    call move_snake
    pop dx
ret
endp

mu proc ;move up
    push dx
    call shift_addrs
    sub sadd,160
    call eat
    call move_snake
    pop dx
ret
endp

md proc ;move down
    push dx
    call shift_addrs
    add sadd,160
    call eat
    call move_snake
    pop dx
ret
endp

shift_addrs proc
    xor ch,ch
    xor bh,bh
    mov cl,snakel
    inc cl
    mov al,2
    mul cl
    mov bl,al
    xor dx,dx
shiftsnake:
    mov dx,sadd[bx-2]
    mov sadd[bx],dx
    sub bx,2
    loop shiftsnake
ret
endp

eat proc
    push ax
    push cx
    mov di,sadd
    es: cmp [di],0
    jz no
    es: cmp [di],20h 
    jz wall
    xor ch,ch
    mov cl,letnum
    xor si,si
lop:
    cmp di,letadd[si]
    jz addf
    add si,2
    loop lop
    jmp wall 
addf:
    mov letadd[si],0
    xor bh,bh
    mov bl,snakel
    es: mov dl,[di]
    mov snake[bx],dl
    es: mov [di],0
    add snakel,1
    sub fin,1
    cmp fin,0
    jz chkletters1
    jmp no
wall:
    cmp di,320     
    jbe wrap_top     
    cmp di,3840    
    jae wrap_bottom       

    mov ax,di
    mov bl,160     
    div bl      
    cmp ah,0   
    jz wrap_left
    mov ax,di
    mov bl,160
    div bl
    cmp ah,158       
    jz wrap_right
    jmp no          

wrap_left:
    add sadd,154    ; Chuy?n sang c?t 79, cùng hàng
    jmp no
wrap_right:
    sub sadd,154    ; Chuy?n sang c?t 0, cùng hàng
    jmp no
wrap_top:
    add sadd,3520   ; Chuy?n sang hàng 23, cùng c?t
    jmp no
wrap_bottom:
    sub sadd,3520   ; Chuy?n sang hàng 2, cùng c?t
    jmp no

chkletters1:
    call move_snake 
    cmp snake[1],'O' 
    jnz endtestl1
    cmp snake[2],'B' 
    jnz endtestl1
    cmp snake[3],'O' 
    jnz endtestl1
    cmp snake[4],'T' 
    jnz endtestl1
    call win         
   
endtestl1:            
    xor bh,bh
    mov bl,hlth
    es: mov [bx+10],0   
    sub hlth,2
    cmp hlth,0
    jnz restc1
    call game_over
restc1:
    call restart
no:
    pop cx
    pop ax
ret
endp

move_snake proc
    xor ch,ch
    xor si,si
    xor bx,bx
    mov cl,snakel
l1mr:
    mov di,sadd[si]
    mov dl,snake[bx]
    mov dh,0bh 
    es: mov word ptr [di],dx
    add si,2
    inc bx
    loop l1mr
    mov di,sadd[si] 
    es: mov word ptr [di],0 
ret
endp

border proc
    mov ah,0
    mov al,3
    int 10h 
    mov ah,6  
    mov al,0  
    mov bh,077h
    mov ch,1  
    mov cl,0  
    mov dh,1  
    mov dl,79 
    int 10h   

    mov ch,2  
    mov cl,0  
    mov dh,23 
    mov dl,0  
    int 10h   

    mov ch,24 
    mov cl,0  
    mov dh,24 
    mov dl,79 
    int 10h  

    mov ch,2  
    mov cl,79 
    mov dh,23 
    mov dl,79 
    int 10h   
ret
endp

restart proc
    xor ch,ch
    xor si,si
    mov cl,snakel
    inc cl
delt:
    mov di,sadd[si]
    es: mov word ptr [di],0
    add si,2
    loop delt

    mov fin,4
    mov sadd,07D2h

    mov cl,snakel 
    inc cl        
    xor si,si
    inc si       
    xor di,di
    add di,2      
emptsn:
    cmp si, 6     
    jae skip_snake_clear
    mov snake[si],0
skip_snake_clear:
    cmp di, 12    
    jae skip_sadd_clear
    mov sadd[di],0
skip_sadd_clear:
    add di,2
    inc si
    loop emptsn
   
    mov snakel,1

    xor ch,ch
    mov cl,letnum
    xor si,si
reslet:
    mov bx,dletadd[si]
    mov letadd[si],bx
    add si,2
    loop reslet

    ; Nhay ve startag de tiep tuc tro choi
    jmp startag
ret
endp

win proc
    call clearall
    call border
    mov di,7BCh
    lea si,gmwin
    mov cx,16 
    mov ah,0eh
lope1w:
    mov al,[si]
    stosw
    inc si
    loop lope1w
    mov di,85Ah
    lea si,endtxt
    mov cx,17 
    mov ah,07h
lope2:
    mov al,[si]
    stosw
    inc si
    loop lope2
qwer1:
    mov ah,7
    int 21h
    cmp al,1bh
    jz ext
    jmp qwer1
ret
endp

game_over proc
    call clearall
    call border
    mov di,7C4h
    lea si,gmov
    mov cx,15 
    mov ah,0ch
lope1:
    mov al,[si]
    stosw
    inc si
    loop lope1
    mov di,862h
    lea si,endtxt
    mov cx,17 
    mov ah,07h
lope2w:
    mov al,[si]
    stosw
    inc si
    loop lope2w
qwer:
    mov ah,7
    int 21h
    cmp al,1bh
    jz ext
    jmp qwer
ret
endp

clearall proc
    xor cx,cx   
    mov dh,24   
    mov dl,79   
    mov bh,00h  
    mov ax,0600h 
    int 10h
ret
endp

end start
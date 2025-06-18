;enter - get nothing ; read char
KeletTav macro
	mov ah,7h          
	int 21h            
endm

;enter - get nothing ; no input
;exit - graphic mode ; set mode 13h
graphicMode macro
	mov ax,13h       
	int 10h           
endm

;enter - get nothing ; no input
;exit - text mode    ; set mode 3
textMode macro
	mov ax,3           
	int 10h            
endm

;enter - get a string ; pass string
;exit - print the tav  ; show string
print macro string
	mov dx,offset string 
	mov ah,9h            
	int 21h              
endm	

openMic macro
	in al, 61h          
	or al, 00000011b     
	out 61h, al          
	mov al, 0B6h         
	out 43h, al          
endm 

closeMic macro
	in al, 61h           
	and al, 11111100b   
	out 61h, al         
endm 

setScreen macro val
	mov ax,val          
	mov es,ax            
endm	

IDEAL                    
MODEL small             
STACK 100h              
DATASEG                 
	jumps
	x dw ?               
	y dw ?               
	color db 15          
	len dw ?             
	height dw ?          
	note dw ?            
	delay   dw 1000      
	Clock equ es:6Ch     
	horaot1 db '                              ',10,13  
			db '    press a-j to reguler notes',10,13   
			db '                              ',10,13   
			db '    w,e,t,y,u to black keys ',10,13    
			db '                            ',10,13     
			db '    press k for a suprise ',10,13       
			db '                              ',10,13     
			db '    press any key except "m" to piano $' 
	menu db '                       ',13,10    
		 db '          press M to open menu $'         
	kolet 	db  'found! $'                              
	flag    db 1       
	exitMsg    db 'goodbye, see you later$'
; --------------------------
; your variables if needed
; --------------------------

CODESEG                 

	
proc delayLoop
	push cx             
	setScreen 40h       
	mov ax,[es:06ch]    ; read current timer
	mov cx,[delay]      ; read our wait time
delayLoop2:
	cmp ax,[es:06ch]    ; compare times
	jz delayLoop2       ; if same, wait
	mov ax,[es:06ch]    ; get time again
	loop delayLoop2     
	setScreen 0a000h    
	pop cx              
	ret                 
endp delayLoop

proc drawPixel
	push cx ax          
	mov bh,0h           
	mov cx,[x]          
	mov dx,[y]         
	mov al,[color]      
	mov ah,0ch          
	int 10h             
	pop ax cx           
	ret                 
endp drawPixel

proc drawLine
	push cx [x]         
	mov cx,[len]        ; how long
pixelLoop:
	call drawPixel      
	inc [x]             ; move next x
	loop pixelLoop      
	pop [x] cx          
	ret                 
endp drawLine

proc rec
	push cx dx [x] [y] [len] [height]  
	mov cx,[height]     ; load height
lineLoop:
	call drawLine       ; draw lines
	inc [y]             
	loop lineLoop       
	pop [height] [len] [y] [x] dx cx    
	ret                 
endp rec

proc playnote
	openMic             ; turn speaker on
	mov ax,[note]       ; load note freq
	out 42h,al          ; low byte
	mov al,ah           ; high byte
	out 42h,al          
	ret                 
endp playnote

proc horaot
	push ax             
	mov ax,13h          
	int 10h             
	mov [x],0           
	mov [y],0           
	mov [len],320       ; 320 wide
	mov [height],200    ; 200 high
	mov [color], 0      ; color=0
	call rec            
	mov dx,offset horaot1 ; horaot1 offset
	mov ah,9h           
	int 21h             
	mov ah,0            
	int 16h             
	mov ax,13h          
	int 10h             
	pop ax              
	ret                 
endp horaot

proc draw
	mov [color],15      ; white
	mov [x],20          
	mov [y],25          
	mov [len],39*7      ; length
	mov [height],150    ; height
	call rec            
	mov cx,6            
	mov [x],59          ; start x
	mov [len],2         
	mov [color], 0      ; black lines
boarder:
	call rec            ; draw a line
	add [x], 39         
	loop boarder        
	mov cx,2            ; 2 black keys
	mov [x],45          
	mov [len],30        ; length
	mov [height],75     
secondTav:
	call rec            ; draw black
	mov [x],85          
	loop secondTav      
	mov [x],162         
	mov [len],30        ; length
	mov [height],75     ; height
	call rec            ; draw black
	mov [x],202         ; next black
	mov [len],30        ; length
	mov [height],75     ; height
	call rec            ; draw black
	mov [x],242         ; next black
	mov [len],30        ; length
	mov [height],75     ; height
	call rec            ; draw black
	ret                 
endp draw

proc do
	mov [x],20          
	mov [y],25          
	mov [len],25        
	mov [color], 7      ; gray
	call rec            
	mov [x],20          
	mov [y],100         
	mov [len],39        ; length
	mov [color],7       ; gray
	call rec            
	mov [note], 4560    ; freq of do
	call playnote       
	ret                 
endp do

proc DoColor
	mov [x],20          
	mov [y],25         
	mov [len],25        ; length
	mov [color], 15     ; white
	call rec            
	mov [x],20          
	mov [y],100         
	mov [len],39        ; length
	mov [color],15      ; white
	call rec            
	ret                 
endp DoColor

proc re 
	mov [x],75          ; re top
	mov [y],25          
	mov [len],10        ; length
	mov [color], 7      ; gray
	call rec            
	mov [x],61          ; re bottom
	mov [y],100         
	mov [len],37        ; length
	mov [color],7       ; gray
	call rec            
	ret                 
endp re 

proc ReColor 
	mov [x],75          
	mov [y],25          
	mov [len],10        ; length
	mov [color],15      ; white
	call rec            
	mov [x],61          ; re bottom
	mov [y],100         
	mov [len],37        ; length
	mov [color],15      ; white
	call rec            
	ret                 
endp ReColor

proc Mi 
	mov [x],115         ; mi top
	mov [y],25          
	mov [len],22        ; length
	mov [color], 7      ; gray
	call rec            
	mov [x],100         ; mi bottom
	mov [y],100         
	mov [len],37        ; length
	mov [color],7       ; gray
	call rec            
	ret                 
endp Mi

proc MiColor
	mov [x],115         ; mi top
	mov [y],25          
	mov [len],22        ; length
	mov [color], 15     ; white
	call rec            
	mov [x],100         ; mi bottom
	mov [y],100         
	mov [len],37        ; length
	mov [color],15      ; white
	call rec            
	ret                 
endp MiColor

proc fa
	mov [x],139         ; fa top
	mov [y],25          
	mov [len],23        ; length
	mov [color], 7      ; gray
	call rec            
	mov [x],139         ; fa bottom
	mov [y],100         
	mov [len],37        ; length
	mov [color],7       ; gray
	call rec            
	ret                 
endp fa

proc FaColor 
	mov [x],139         ; fa top
	mov [y],25          
	mov [len],23        ; length
	mov [color], 15     ; white
	call rec            
	mov [x],139         ; fa bottom
	mov [y],100         
	mov [len],37        ; length
	mov [color],15      ; white
	call rec            
	ret                 
endp FaColor
	
proc sol
	mov [x],192         ; sol top
	mov [y],25          
	mov [len],10        ; length
	mov [color], 7      ; gray
	call rec           
	mov [x],178         ; sol bottom
	mov [y],100        
	mov [len],37        ; length
	mov [color],7       ; gray
	call rec           
	ret                
endp sol

proc SolColor
	mov [x],192         ; sol top
	mov [y],25         
	mov [len],10        ; length
	mov [color], 15     ; white
	call rec          
	mov [x],178         ; sol bottom
	mov [y],100         
	mov [len],37        ; length
	mov [color],15      ; white
	call rec            
	ret                 
endp SolColor

proc la
	mov [x],232         ; la top
	mov [y],25          
	mov [len],10        ; length
	mov [color],7       ; gray
	call rec            
	mov [x],217         ; la bottom
	mov [y],100         
	mov [len],37        ; length
	mov [color],7       ; gray
	call rec            
	ret                 
endp la 

proc laColor
	mov [x],232         ; la top
	mov [y],25          
	mov [len],10        ; length
	mov [color],15      ; white
	call rec            
	mov [x],217         ; la bottom
	mov [y],100         
	mov [len],37        ; length
	mov [color],15      ; white
	call rec            
	ret                 
endp laColor

proc sii
	mov [x],272         ; si top
	mov [y],25         
	mov [len],21        ; length
	mov [color], 7      ; gray
	call rec            
	mov [x],256         ; si bottom
	mov [y],100         
	mov [len],37        ; length
	mov [color],7       ; gray
	call rec            
	ret                
endp sii

proc siiColor
	mov [x],272         
	mov [y],25          
	mov [len],21        
	mov [color], 15     ; white
	call rec            
	mov [x],256         
	mov [y],100         
	mov [len],37        
	mov [color],15      ; white
	call rec            
	ret                
endp siiColor

start:
	mov ax, @data       
	mov ds, ax        
	mov ax,13h          
	int 10h             
	mov dx, offset menu 
	mov ah,9h           ; print
	int 21h             
	call draw           ; draw keys
WaitForData: 
	mov [height],75     
	in al, 64h          
	cmp al, 10b         
	je	WaitForData    ; keep waiting
	in 	al, 60h         ; read key
	cmp al, 1h          ; ESC?
	je exitmsglabel             ; if yes, exit
	cmp al,32h          ; 'm'?
	jz press_m          ; if yes, menu
	cmp al,9eh          ; key up A
	jz doRecaller       ; release do
	cmp al,1eh          ; key down A
	je do1              ; press do
	cmp al,9fh          ; key up S
	jz reRecaller       ; release re
	cmp al,1fh          ; key down S
	je re1              ; press re
	cmp al,0a0h         ; key up D
	jz miRecaller       ; release mi
	cmp al,20h          ; key down D
	jz mi1              ; press mi
	cmp al,0a1h         ; key up F
	jz faRecaler        ; release fa
	cmp al,21h          ; key down F
	jz fa1              ; press fa
	cmp al,0a2h         ; key up G
	jz solRecaler       ; release sol
	cmp al,22h          ; key down G
	jz sol1             ; press sol
	cmp al,0a3h         ; key up H
	jz laRecaler        ; release la
	cmp al,23h          ; key down H
	jz la1              ; press la
	cmp al,0a4h         ; key up J
	jz siRecaler        ; release si
	cmp al,24h          ; key down J
	jz sii1             ; press si
	cmp al,91h          ; key up W
	jz asRecaller       ; release black
	cmp al,11h          ; key down W
	jz as               ; press black
	cmp al,92h          ; key up E
	jz sdRecaller       ; release black
	cmp al,12h          ; key down E
	jz sd               ; press black
	cmp al,94h          ; key up T
	jz fgRecaller       ; release black
	cmp al,14h          ; key down T
	jz fg               ; press black
	cmp al,95h          ; key up Y
	jz ghRecaller       ; release black
	cmp al,15h          ; key down Y
	jz gh               ; press black
	cmp al,96h          ; key up U
	jz hjRecaller       ; release black
	cmp al,16h          ; key down U
	jz hj               ; press black
	cmp al,25h          ; k key
	jz yonatan          ; do tune
	cmp al,0a5h         ; key up K
	
	jnz WaitForData     ; else keep waiting
	
	mov [flag],1        
	jmp WaitForData     

press_m:
	graphicMode         
	print horaot1       ; print instructions
	mov ah,00h          ; wait key
	int 16h             ; do wait
	graphicMode         
	print menu          ; show short menu
	call draw           ; draw keys again
	jmp WaitForData     

doRecaller:
	call DoColor        ; turn do white
	closeMic            ; no beep
	jmp WaitForData     
reRecaller:
	call ReColor        ; turn re white
	closeMic            ; no beep
	jmp WaitForData     
miRecaller:
	call MiColor        ; turn mi white
	closeMic            ; no beep
	jmp WaitForData     
faRecaler:
	call FaColor        ; turn fa white
	closeMic            ; no beep
	jmp WaitForData     
solRecaler:
	call SolColor       ; turn sol white
	closeMic            ; no beep
	jmp WaitForData     
laRecaler:
	call laColor        ; turn la white
	closeMic            ; no beep
	jmp WaitForData     
siRecaler:
	call siiColor       ; turn si white
	closeMic            ; no beep
	jmp WaitForData     
asRecaller:
	mov [x],46          ; black x
	mov [y],25          ; black y
	mov [len],28        
	mov [height],74     ; height
	mov [color],0       ; black
	call rec           
	closeMic           
	jmp WaitForData     
sdRecaller:
	mov [x],86          ; black x
	mov [y],25          ; black y
	mov [len],28        
	mov [height],74     ; height
	mov [color],0       ; black
	call rec           
	closeMic            
	jmp WaitForData     
fgRecaller:
	mov [x],163         ; black x
	mov [y],25          ; black y
	mov [len],28        
	mov [height],74     ; height
	mov [color],0       ; black
	call rec            
	closeMic            
	jmp WaitForData     
ghRecaller:
	mov [x],203         ; black x
	mov [y],25          ; black y
	mov [len],28        
	mov [height],74     ; height
	mov [color],0       ; black
	call rec            ; fill black
	closeMic            
	jmp WaitForData     
hjRecaller:
	mov [x],243         ; black x
	mov [y],25          ; black y
	mov [len],28        
	mov [height],74     ; height
	mov [color],0       ; black
	call rec            
	closeMic            
	jmp WaitForData     

do1:
	call do            ; color do
	mov [note], 4560   ; freq
	call playnote     
	jmp WaitForData    
re1:	
	call re            ; color re
	mov [note], 4061   ; freq
	call playnote      
	jmp WaitForData    
mi1:
	call Mi            ; color mi
	mov [note], 3615   ; freq
	call playnote      
	jmp WaitForData    
fa1:
	call fa            ; color fa
	mov [note], 3413   ; freq
	call playnote      
	jmp WaitForData    
sol1:
	call sol           ; color sol
	mov [note], 3047   ; freq
	call playnote      
	jmp WaitForData    
la1:
	call la            ; color la
	mov [note], 2712   ; freq
	call playnote      
	jmp WaitForData    
sii1:
	call sii           ; color si
	mov [note], 2416   ; freq
	call playnote     
	jmp WaitForData    

as:
	mov [x],46         
	mov [y],25         
	mov [len],28       ; length
	mov [height],74    ; height
	mov [color],14     
	call rec          
	mov [note], 4293   ; freq
	call playnote      
	jmp WaitForData    
sd:
	mov [x],86       
	mov [y],25        
	mov [len],28       ; length
	mov [height],74    ; height
	mov [color],14     
	call rec           
	mov [note], 3825   ; freq
	call playnote      
	jmp WaitForData   
fg:
	mov [x],163        
	mov [y],25      
	mov [len],28       ; length
	mov [height],74    ; height
	mov [color],14    
	call rec          
	mov [note], 3225   ; freq
	call playnote     
	jmp WaitForData    
gh:
	mov [x],203        
	mov [y],25        
	mov [len],28       ; length
	mov [height],74    ; height
	mov [color],14     
	call rec         
	mov [note], 2869   ; freq
	call playnote     
	jmp WaitForData    
hj:
	mov [x],243       
	mov [y],25         
	mov [len],28       ; length
	mov [height],74    ; height
	mov [color],14    
	call rec           
	mov [note], 2555   ; freq
	call playnote    
	jmp WaitForData
	
suprise:
	cmp [flag],1        ; if 1, do tune
	jnz ending          ; else skip
	mov [note], 4560    ; do
	call playnote   
	mov [delay],10       
	call delayLoop      ; do wait
	closeMic            ; off
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 4293    ; diaz		
	call playnote       
	mov [delay],3       
	call delayLoop
	closeMic       
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 3825    ; diaz		
	call playnote       
	mov [delay],6       
	call delayLoop
	closeMic       
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 3825    ; diaz		
	call playnote       
	mov [delay],6       
	call delayLoop
	closeMic       
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 3825    ; diaz		
	call playnote       
	mov [delay],6       
	call delayLoop  
	closeMic       
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 2869    ; fa diaz		
	call playnote       
	mov [delay],6       
	call delayLoop
	closeMic    	
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 2869    ; fa diaz		
	call playnote       
	mov [delay],6       
	call delayLoop
	closeMic  
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 4560    ; do
	call playnote   
	mov [delay],9       
	call delayLoop      ; do wait
	closeMic 
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 2555    ; do
	call playnote   
	mov [delay],3       
	call delayLoop      ; do wait
	closeMic 
	mov [delay],1      
	call delayLoop      ; wait
	mov [note], 2869    ; fa diaz		
	call playnote       
	mov [delay],3       
	call delayLoop
	closeMic    
	jmp WaitForData
	
; ANIMATION
yonatan:
	cmp [flag],1        ; if 1, do tune
	jnz ending          ; else skip
	mov [note], 3047    ; sol
	call playnote   
	call sol
	mov [delay],6       
	call delayLoop      ; do wait
	call SolColor
	closeMic            ; off
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 3615    ; mi
	call Mi				;color mi key
	call playnote       
	mov [delay],6      
	call delayLoop      ; wait
	call MiColor		;ReColor
	closeMic           
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 3615    ; mi again
	call playnote      
	call Mi				;color mi key
	mov [delay],6       
	call delayLoop      ; wait
	call MiColor		;recolor mi color
	closeMic          
	mov [delay],6       
	call delayLoop      ; wait
	mov [note], 3413    ; fa
	call playnote       
	call fa				;color fa key
	mov [delay],6       
	call delayLoop      ; wait
	call FaColor        ;recolor fa key
	closeMic          
	mov [delay],2       
	call delayLoop      ; wait
	mov [note], 4061    ; re
	call playnote       
	call re				;color re key
	mov [delay],6      
	call delayLoop      ; wait
	call ReColor		;recolor re key
	closeMic            
	mov [delay],2       
	call delayLoop      ; wait
	mov [note], 4061    ; re again
	call playnote       
	call re
	mov [delay],6       
	call delayLoop      ; wait
	call ReColor		;recolor re key
	closeMic            
	mov [delay],6       
	call delayLoop      ; wait
	mov [note], 4560    ; do
	call playnote       
	call do				;color do key
	mov [delay],6       
	call delayLoop      ; wait
	call DoColor		;recolor do key
	closeMic           
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 4061    ; re
	call playnote       
	call re				;recolor re key
	mov [delay],6       ;
	call delayLoop      ; wait
	call ReColor		;recolor re key
	closeMic            
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 3615    ; mi
	call playnote      
	call Mi				;color Mi
	mov [delay],6      
	call delayLoop      ; wait
	call MiColor		;recolor Mi
	closeMic            
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 3413    ; fa
	call playnote      
	call fa				;color fa key
	mov [delay],6      
	call delayLoop      ; wait
	call FaColor		;recolor fa
	closeMic           
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 3047    ; sol
	call playnote       
	call sol			;sol color
	mov [delay],6      
	call delayLoop      ; wait
	call SolColor		;recolor sol key
	closeMic            
	mov [delay],2       
	call delayLoop      ; wait
	mov [note], 3047    ; sol
	call playnote       
	call sol
	mov [delay],6       
	call delayLoop      ; wait
	call SolColor		;recolor key sol
	closeMic           
	mov [delay],2       
	call delayLoop     
	mov [note], 3047    ; sol
	call playnote       
	call sol			;color sol key
	mov [delay],6       
	call delayLoop      ; wait
	call SolColor		;recolor sol key
	closeMic            
	mov [delay],6       
	call delayLoop      ; wait
	cmp [flag],1        ; check flag again
	jnz ending         
	mov [note], 3047    ; sol again
	call playnote       
	call sol			;play sol key
	mov [delay],6       
	call delayLoop      ; wait
	call SolColor		;recolor sol key
	closeMic            
	mov [delay],2      
	call delayLoop      ; wait
	mov [note], 3615    ; mi
	call playnote       
	call Mi				;color Mi
	mov [delay],6       
	call delayLoop      ; wait
	call MiColor		;recolor Mi key
	closeMic           
	mov [delay],2       
	call delayLoop      ; wait
	mov [note], 3615    ; mi again
	call playnote      
	call Mi				;color Mi
	mov [delay],6      
	call delayLoop      ; wait
	call MiColor		;ReColor
	closeMic            
	mov [delay],6       
	call delayLoop      ; wait
	mov [note], 3413    ; fa
	call playnote       
	call fa				;color fa
	mov [delay],6       
	call delayLoop      ; wait
	call FaColor		;recolor key
	closeMic            
	mov [delay],2       
	call delayLoop      ; wait
	mov [note], 4061    ; re
	call playnote       
	call re
	mov [delay],6       
	call delayLoop      ; wait
	call ReColor		;re ReColor
	closeMic            
	mov [delay],2       
	call delayLoop      ; wait
	mov [note], 4061    ; re again
	call playnote       
	call re				;color re
	mov [delay],6       
	call delayLoop      ; wait
	call ReColor		;recoloer re
	closeMic            
	mov [delay],6       
	call delayLoop      ; wait
	mov [note], 4560    ; do
	call playnote       
	call do
	mov [delay],6       
	call delayLoop      ; wait
	call DoColor		;recolor re
	closeMic            
	mov [note], 3615    ; mi
	call playnote       
	call Mi				;color Mi
	mov [delay],6       
	call delayLoop      ; wait
	call MiColor		;MiColor
	closeMic           
	mov [note], 3047    ; sol
	call playnote       
	call sol			;color sol
	mov [delay],6       
	call delayLoop      ; wait
	call SolColor		;recolor sol
	closeMic            
	mov [delay],2       
	call delayLoop      ; wait
	mov [note], 3047    ; sol
	call playnote       
	call sol			;color sol
	mov [delay],6       
	call delayLoop      ; wait
	call SolColor		;recolor sol color
	closeMic            
	mov [delay],2       
	call delayLoop      ; wait
	mov [note], 4560    ; do
	call playnote       
	call do
	mov [delay],6       
	call delayLoop      ; wait
	call DoColor		;ercolor do color
	closeMic            
	mov [flag],0        
ending:	
	jmp WaitForData  
exitmsglabel:
	mov ax,3h
	int 10h
	mov dx,offset exitMsg
	mov ah,9h
	int 21h
	jmp exit

exit:
	closeMic            ; speaker off
	mov ax, 4c00h       
	int 21h     

END start              

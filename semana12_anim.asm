; ============================================================
; Semana 12 - Laboratorio (Parte 2): Animacion basica
; ============================================================
; Ensamblar : uasm64 -win64 semana12_anim.asm
; Enlazar   : GoLink.exe semana12_anim.obj kernel32.dll /fo semana12_anim.exe /console /entry main
; ------------------------------------------------------------

extrn GetStdHandle: proc
extrn SetConsoleCursorPosition: proc
extrn SetConsoleTextAttribute: proc
extrn WriteConsoleA: proc
extrn FillConsoleOutputCharacterA: proc
extrn FillConsoleOutputAttribute: proc
extrn Sleep: proc
extrn ExitProcess: proc

; ------------------------------------------------------------
; CONFIGURACION: modifica estos valores para la actividad
; ------------------------------------------------------------
FILA        = 10    ; fila por la que se mueve el caracter
COLUMNA_FIN = 70    ; el movimiento termina al llegar a esta columna
RETARDO_MS  = 20    ; milisegundos entre cada paso (menor = mas rapido)
ATRIBUTO    = 0Ah   ; fondo negro (0) + texto verde brillante (A)

.data
 hConsole  dq 0
 caracter  db '#', 0            ; caracter animado (prueba 'O' o '#')
 espacio   db ' ', 0            ; se usa para borrar el rastro
 escritos  dq 0
 pos_x     dw 0                 ; columna actual
 pos_y     dw FILA              ; fila fija

 ; Variables para limpiar la pantalla
 leidos    dd 0
 homeCoord dd 0                 ; COORD (0,0)
 numCeldas dd 2000              ; 80 columnas x 25 filas

.code
main proc
 
 sub rsp, 28h

 ; ---- Obtener el handle de la consola ----
 mov rcx, -11
 call GetStdHandle
 mov [hConsole], rax
 mov rbx, rax

 ; LIMPIAR LA PANTALLA

 mov rcx, rbx
 mov rdx, 20h                   ; espacio
 mov r8d, [numCeldas]
 mov r9d, [homeCoord]
 lea rax, leidos
 mov qword ptr [rsp + 20h], rax
 call FillConsoleOutputCharacterA

 mov rcx, rbx
 mov rdx, 07h                   ; atributo por defecto
 mov r8d, [numCeldas]
 mov r9d, [homeCoord]
 lea rax, leidos
 mov qword ptr [rsp + 20h], rax
 call FillConsoleOutputAttribute

 ; ---- Color del caracter 
 mov rcx, rbx
 mov rdx, ATRIBUTO
 call SetConsoleTextAttribute

 ; ---- Empezar en la columna 0 ----
 mov word ptr [pos_x], 0

anim_loop:
 cmp word ptr [pos_x], 0
 je pintar_caracter             ; en la columna 0 no hay nada que borrar atras

 ; ---- Borrar la posicion anterior (X-1) escribiendo un espacio ----
 mov rcx, rbx
 movzx rdx, word ptr [pos_x]
 dec rdx                        ; X-1 (seguro porque X > 0)
 movzx rax, word ptr [pos_y]
 shl rax, 16                    ; Y en los 16 bits altos
 or rdx, rax                    ; COORD = (Y << 16) | (X-1)
 call SetConsoleCursorPosition

 mov rcx, rbx
 lea rdx, espacio
 mov r8, 1
 lea r9, escritos
 mov qword ptr [rsp + 20h], 0
 call WriteConsoleA

pintar_caracter:
 ; ---- Mover el cursor a la posicion nueva
 mov rcx, rbx
 movzx rdx, word ptr [pos_x]
 movzx rax, word ptr [pos_y]
 shl rax, 16
 or rdx, rax                    ; COORD = (Y << 16) | X
 call SetConsoleCursorPosition

 ; ---- Escribir el caracter
 mov rcx, rbx
 lea rdx, caracter
 mov r8, 1
 lea r9, escritos
 mov qword ptr [rsp + 20h], 0
 call WriteConsoleA

 ; ---- Retardo ----
 mov rcx, RETARDO_MS
 call Sleep

 ; ---- Siguiente columna y comprobar fin ----
 inc word ptr [pos_x]
 cmp word ptr [pos_x], COLUMNA_FIN
 jl anim_loop


 mov rcx, rbx
 mov rdx, 07h
 call SetConsoleTextAttribute

 mov rcx, rbx
 mov rdx, ((FILA + 3) shl 16)   ; cursor en (0, FILA+3)
 call SetConsoleCursorPosition

 ; ---- Terminar 
 xor ecx, ecx
 call ExitProcess
main endp
end

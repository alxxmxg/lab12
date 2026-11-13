; ============================================================
; Semana 12 - Laboratorio (Parte 1): Pintar un caracter en color
; ============================================================
; Ensamblar : uasm64 -win64 semana12.asm
; Enlazar   : GoLink.exe semana12.obj kernel32.dll /fo semana12.exe /console /entry main
; ------------------------------------------------------------


extrn GetStdHandle: proc
extrn SetConsoleCursorPosition: proc
extrn SetConsoleTextAttribute: proc
extrn WriteConsoleA: proc
extrn FillConsoleOutputCharacterA: proc     ; limpia los caracteres
extrn FillConsoleOutputAttribute: proc      ; limpia los colores
extrn ExitProcess: proc

;
COLUMNA  = 30
FILA     = 12
ATRIBUTO = 4Fh      
                

.data
 hConsole  dq 0
 caracter  db 'X', 0            ; caracter que se va a pintar
 escritos  dq 0                 ; WriteConsoleA devuelve aqui cuantos escribio

 ; Variables para limpiar la pantalla
 leidos    dd 0                 ; celdas procesadas por FillConsoleOutput*
 homeCoord dd 0                 ; COORD (0,0): punto de inicio de la limpieza
 numCeldas dd 2000              ; 80 columnas x 25 filas

.code
main proc
 
 sub rsp, 28h

 mov rcx, -11
 call GetStdHandle
 mov [hConsole], rax
 mov rbx, rax                   ; RBX conserva el handle entre llamadas

 ; LIMPIAR LA PANTALLA
 mov rcx, rbx                   ; 1) handle
 mov rdx, 20h                   ; 2) caracter espacio ' '
 mov r8d, [numCeldas]           ; 3) cuantas celdas
 mov r9d, [homeCoord]           ; 4) coordenada inicial (0,0)
 lea rax, leidos
 mov qword ptr [rsp + 20h], rax ; 5) puntero a "celdas escritas" (en la pila)
 call FillConsoleOutputCharacterA

 mov rcx, rbx
 mov rdx, 07h                   ; atributo por defecto: texto blanco, fondo negro
 mov r8d, [numCeldas]
 mov r9d, [homeCoord]
 lea rax, leidos
 mov qword ptr [rsp + 20h], rax
 call FillConsoleOutputAttribute

 ; MOVER EL CURSOR A (COLUMNA, FILA)

 mov rcx, rbx
 mov rdx, (FILA shl 16) or COLUMNA
 call SetConsoleCursorPosition

 ; ---- Cambiar el color del texto que se va a escribir 
 mov rcx, rbx
 mov rdx, ATRIBUTO
 call SetConsoleTextAttribute

 ; ---- Escribir el caracter
 mov rcx, rbx
 lea rdx, caracter
 mov r8, 1                      ; longitud: 1 caracter
 lea r9, escritos
 mov qword ptr [rsp + 20h], 0   ; 5to parametro (reservado) = NULL
 call WriteConsoleA

 ; ---- Dejar la consola en condiciones para el prompt
 mov rcx, rbx
 mov rdx, 07h                   ; color normal
 call SetConsoleTextAttribute

 mov rcx, rbx
 mov rdx, ((FILA + 3) shl 16)   ; cursor en (0, FILA+3)
 call SetConsoleCursorPosition

 ; ---- Terminar
 xor ecx, ecx
 call ExitProcess
main endp
end

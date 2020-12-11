TITLE Program 6     (Proj6_marcusz.asm)

; Author: Zach Marcus
; Last Modified: December 5, 2020
; OSU email address: marcusz@oregonstate.edu
; Course number/section:   CS271 Section 401
; Project Number:  6               Due Date: December 6, 2020
; Description: This program has the user input 10 numbers, which are initially read in as strings.
;              It then converts those string values into integers, stores them within an array,
;              and prints them back out as strings. It then prints out the sum of the integers as a string,
;              as well as the rounded average as a string. 

INCLUDE Irvine32.inc


; macros


; name:           mGetString
; description:    displays a prompt, then inserts user input into specified inputAddress
; preconditions:  none
; postconditions: none
; receives:       prompt, inputAddress
; returns:        none
mGetString MACRO prompt, inputAddress
	MOV   EDX, prompt
	CALL  WriteString
	MOV   EDX, inputAddress
	MOV   ECX, 32
	CALL  ReadString
ENDM


; name:           mDisplayString
; description:    prints string at inputAddress
; preconditions:  none
; postconditions: none
; receives:       inputAddress
; returns:        none
mDisplayString MACRO inputAddress
	MOV   EDX, inputAddress
	CALL  WriteString
ENDM


; name:           resetString
; description:    copies the values in string1 into string2
; preconditions:  none
; postconditions: none
; receives:       string1, string2
; returns:        none
resetString MACRO string1, string2
	CLD
	MOV   ECX,   32
	MOV   ESI, OFFSET string1
	MOV   EDI, OFFSET string2
	REP   MOVSB
ENDM


.data
intro1	  BYTE	  "Program 6: Low-level I/O Procedures",0
intro2	  BYTE    "Written by Zach Marcus",0
intro3    BYTE    "Please provide 10 signed decimal integers. Each number needs to be small enough to fit inside a 32-bit",13,10,
				  "register. After you've finished inputting the raw numbers, I'll display a list of the integers,",13,10,
				  "their sum, and their average value.",0
prompt    BYTE    "Please enter a signed number: ",0
checkVal  BYTE    " ",0
savedVal  SDWORD  ?
stringVal BYTE    32 DUP(?)
newString DWORD   32 DUP(?)
string2   BYTE    32 DUP(?)
newStr2   DWORD   32 DUP(?)
numbers   SDWORD  10 DUP(?)
resetStr  DWORD   32 DUP(?)
arrSize   DWORD   ?
error     BYTE    "ERROR: You did not enter a signed number or your number was too big.",0
signCheck DWORD   0
counter   DWORD   11
ntrString BYTE    "You entered the following numbers:",0
sumString BYTE    "The sum of these numbers is: ",0
avgString BYTE    "The rounded average is: ",0
endString BYTE    "Goodbye, and thanks for using the program!",0
comma     BYTE    ", ",0
sum       DWORD   ?
avg       DWORD   ?


.code
main PROC


	; introduce the program


	PUSH	OFFSET intro1
	PUSH	OFFSET intro2
	PUSH    OFFSET intro3
	CALL    introduction


	; get numbers from user

	
	; set up counter for loop
	MOV     ECX,   counter
	MOV     EDI,   OFFSET numbers

	getNumbers:
		CLD
		PUSH    EDI
		PUSH    OFFSET savedVal
		PUSH    OFFSET signCheck
		PUSH    OFFSET arrSize
		PUSH    OFFSET checkVal
		PUSH    OFFSET prompt
		PUSH    OFFSET numbers
		PUSH    OFFSET error
		CALL    ReadVal

		; save entered value into numbers array
		POP     EDI
		CLD
		MOV     EAX,   savedVal
		STOSD
		DEC     counter
		MOV     ECX,   counter
	LOOP    getNumbers


	; print the numbers in a list


	; display prompt for user to enter number
	CALL CrLf
	MOV  EDX, OFFSET ntrString
	CALL WriteString
	CALL CrLf

	; set up counter
	MOV   counter,   11
	MOV   ECX,       counter
	MOV   ESI,       OFFSET numbers

	printNumbers:
	; reset strings for procedure
		PUSH    ESI
		resetString OFFSET resetStr, OFFSET newString
		resetString OFFSET resetStr, OFFSET stringVal
		POP     ESI

		CLD
		LODSD
		PUSH    ESI
		PUSH    signCheck
		PUSH    OFFSET newString
		PUSH    EAX
		PUSH    OFFSET stringVal
		CALL    WriteVal 

		; print comma if not at last number
		CMP     counter,   2                
		JE      noComma
		MOV     EDX,       OFFSET comma
		CALL    WriteString

		noComma:
		POP     ESI
		DEC     counter
		MOV     ECX,   counter
	LOOP    printNumbers


	; display the sum


	; find the sum 
	CALL CrLf
	MOV  EDX, OFFSET sumString
	CALL WriteString

	; set up counter
	MOV   counter,   11
	MOV   ECX,       counter
	MOV   ESI,       OFFSET numbers
	MOV   EBX,       0

	; calculate the sum
	sumNumbers:
		CLD
		LODSD
		ADD   EBX,   EAX
	LOOP sumNumbers

	; reset strings for procedure
	PUSH    ESI
	resetString OFFSET resetStr, OFFSET newString
	resetString OFFSET resetStr, OFFSET stringVal
	POP     ESI

	; display the sum
	MOV     sum,  EBX
	PUSH    signCheck
	PUSH    OFFSET newString
	PUSH    sum
	PUSH    OFFSET stringVal
	CALL    WriteVal 
	CALL    CrLf


	; display the average


	; calculate the rounded average
	MOV     EDX,   0
	MOV     EAX,   sum
	MOV     EBX,   10
	CDQ
	IDIV    EBX
	MOV     avg,   EAX

	MOV     EDX,   OFFSET avgString
	CALL    WriteString

	; reset strings for procedure
	PUSH    ESI
	resetString OFFSET resetStr, OFFSET newString
	resetString OFFSET resetStr, OFFSET stringVal
	POP     ESI

	; display the average
	PUSH    signCheck
	PUSH    OFFSET newStr2
	PUSH    avg
	PUSH    OFFSET string2
	CALL    WriteVal 
	CALL    CrLf
	CALL    CrLf


	; show a farewell


	; display farewell string
	MOV     EDX,   OFFSET endString
	CALL    WriteString
	CALL    CrLf


	Invoke ExitProcess,0	; exit to operating system
main ENDP


; procedures


; name:           introduction
; description:    used at start of program to display introduction and instructions
; preconditions:  none
; postconditions: none
; receives:       intro1,   intro2,   intro3
;                 [EBP+16], [EBP+12], [EBP+8]
; returns:        none
introduction PROC
	PUSH	EBP
	MOV     EBP,   ESP

	MOV     EDX,   [EBP+16]
	CALL    WriteString
	CALL    CrLf
	MOV     EDX,   [EBP+12]
	CALL    WriteString
	CALL    CrLf
	CALL    CrLf

	MOV     EDX,   [EBP+8]
	CALL    WriteString
	CALL    CrLf
	CALL    CrLf
	
	POP     EBP
	RET     8
introduction ENDP


; name:           ReadVal
; description:    this procedure uses the mGetString macro to get user input, then converts that input string
;                 into a signed doubleword, checking that no letters or symbols were entered, and that it fits 
;                 within a 32-bit register, then stores it in the savedVal memory variable
; preconditions:  none
; postconditions: none
; receives:       savedVal, signCheck, arraySize, checkVal, prompt,   inputAddress, errorMessage
;                 [EBP+32], [EBP+28],  [EBP+24],  [EBP+20], [EBP+16], [EBP+12],     [EBP+8]
; returns:        savedVal      
ReadVal PROC

	PUSH	EBP
	MOV     EBP,   ESP

	; preserve registers
	PUSHAD

	; get user input
	getInput:
	MOV     EDX,   [EBP+28]                ; reset signCheck, since new loop. This is used to check if a sign has been encountered
	MOV     EBX,   0
	MOV     [EDX], EBX                       
	mGetString [EBP+16],[EBP+20]

	; validate user input
	MOV     [EBP+24],   EAX                ; EAX contains arraySize, actual amount of characters entered
	MOV     EBX,        [EBP+24]           ; save arraySize
	MOV     ECX,        [EBP+24]
	MOV     ESI,        [EBP+20]           ; checkVal  

	startCheck:
	CLD
	LODSB
	MOV     EDX,        [EBP+28]           ; set EDX equal to signCheck
	CMP     [EDX],      DWORD PTR  1                  
	JE      pastSigns

	; check if first byte entered is a sign, or space
	CMP     AL,         2Bh                       
	JE      endCheck
	CMP     AL,         2Dh
	JE      endCheck
	CMP     AL,         20h
	JE      enterError

	pastSigns:                             ; check if byte is within range
		CMP     AL,         2Bh                       
		JE      enterError
		CMP     AL,         2Dh
		JE      enterError
		CMP     AL,         20h
	    JE      enterError
		CMP     AL,         30h
		JG      maxCompare
		JMP     endLoop

	maxCompare:
		CMP   AL,  39h
		JG    enterError
		JMP   endCheck

	enterError:
		MOV   EDX, [EBP+8]
		CALL  WriteString 
		CALL  CrLf
		JMP   getInput

	endCheck:
	MOV     EDX,        [EBP+28]           ; check signCheck, if first sign has already been encountered
	CMP     [EDX],      DWORD PTR 1
	JE      endLoop
	MOV     [EDX],      DWORD PTR 1

	endLoop:
	LOOP    startCheck

	; convert user input to digit
	MOV     [EBP+24],    EBX              
	MOV     ECX,         [EBP+24]          ; loop counter
	MOV     EBX,         1
	MOV     EDX,         0                 ; what the number will be when summed 
	DEC     ESI                            ; set ESI equal to last character entered, just before null-terminated value  
	
	; loop backwards through string, converting each byte
	convertLoop:
		MOV    EAX,     0
		STD
		LODSB
		; check if byte is a sign
		CMP    AL,      2Bh
		JE     makePositive
		CMP    AL,      2Dh
		JE     makeNegative
		SUB    AL,      48

		; multiply byte by its power of 10
		PUSH   EDX
		MUL    EBX
		POP    EDX
		ADD    EDX,     EAX                ; store overall value in EDX
		JO     enterError                  ; go to error if number is too big

		; get the next value of 10 
		MOV    EAX,     EBX
		MOV    EBX,     10
		PUSH   EDX
		MUL    EBX
		POP    EDX
		MOV    EBX,     EAX
		LOOP   convertLoop

		; put number in EAX
		MOV    EAX,     EDX
		JMP endConvertLoop

		makeNegative:
		; this occurs when a negative sign is encountered
		; stop looping and make number negative
		MOV    EAX,     EDX
		MOV    EDX,     -1
		MUL    EDX
		JMP    endConvertLoop

		makePositive:
		; this occurs when a positive sign is encountered
		; stop processing number
		MOV    EAX,     EDX

	endConvertLoop:
	; store user input
	storeInput:
	MOV   EDI,    [EBP+32]
	MOV   [EDI],  EAX

	; preserve registers
	POPAD

	veryEnd:
	POP   EBP
	RET   28
ReadVal ENDP


; name:           WriteVal
; description:    this procedure converts a doubleword into a string of ascii digits, then
;                 invokes the mDisplayString macro to print the ascii string
; preconditions:  none
; postconditions: none
; receives:       signCheck, newString, savedVal, stringVal
;                 [EBP+20],  [EBP+16],  [EBP+12], [EBP+8]
; returns:        stringVal      
WriteVal PROC

	PUSH   EBP
	MOV    EBP,   ESP

	; preserve registers
	PUSHAD

	; reset signCheck
	MOV    EBX,   0
	MOV    [EBP+20], EBX 

	; set count to 0, will be used for reversing string
	MOV    ECX,   0

	; set EDI equal to string array
	MOV    EDI,   [EBP+8]

	; set EAX equal to saved digit
	MOV    EAX,   [EBP+12]
	
	CMP    EAX,   0                        ; check if number is negative
	JGE    divideLoop
	MOV    EBX,   1
	MOV    [EBP+20], EBX                   ; set signCheck
	MOV    EBX,   -1
	IMUL   EBX                             ; reverse the negative for now

	divideLoop:
	; divide EAX by multiples of 10, saving each remainder
		ADD     ECX,  1
		CLD
		MOV     EDX,  0
		MOV     EBX,  10
		IDIV    EBX
		PUSH    EAX
		MOV     EAX,  EDX
		ADD     EAX,  30h
		STOSB   
		POP     EAX
		CMP     EAX,  0
		JE      endDivideLoop
		JMP     divideLoop
	endDivideLoop:

	; set ESI equal to string
	MOV   ESI,   EDI

	; check if signCheck is set
	MOV   EBX,   0
	CMP   [EBP+20],EBX
	JE    regularReverse

	; append a minus to front of string
	MOV   EAX,   2Dh
	MOV   EDI,   [EBP+16]
	CLD
	STOSB
	DEC   ESI
	JMP   reverseLoop 

	regularReverse:
	DEC   ESI
	MOV   EDI,   [EBP+16]	               ; set EDI equal to new string
	reverseLoop:
		STD
		LODSB
		CLD
		STOSB
		LOOP reverseLoop
		
	; use macro to display string
	mDisplayString [EBP+16]

	; preserve registers
	POPAD

	POP     EBP
	RET     16
WriteVal ENDP


END main
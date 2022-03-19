TITLE Program 6 - String Primitives and Macros		    (Proj6_ThatChes.asm)

; Author: Steve Thatcher
; Last Modified: 06/06/2021
; OSU email address: thatches@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:   6              Due Date:  06/06/2021
; Description: This file contains a program which requests 10 integers that fit within a 32-bit signed register. 
; All reading and writing is done using Irving Read/Write String ONLY, not use of Read/Write Dec or Int used. 
; Reading and writing is done through two macros called throughout the program. 
; Integers are read as strings, converted to integers and stored in a 10 element array. 
; Integers from arrays are converted back to strings for display. 
; Integer strings are displayed, along with sum and average, which is rounded down. 
; All loops are tracked and initiated from main, along with all procedure calls. 

INCLUDE Irvine32.inc



; ***************************************************************
; Name: mGetString
; Macro used any time the program needs to read input from the user, uses Irving ReadString to receive input, and uses mDisplayString
; macro to display the input prompt to the user. 
; receives: Two parameters, the OFFSET address of a temporary variable location, and the OFFSET address of the input prompt string for display.
; returns:	Saved value of ReadString input stored in passed temporary storage variable.
; preconditions:	Two parameters passed with temporary storage variable and OFFSET address of user input prompt 
; registers changed: EAX, ECX, EDX
; ***************************************************************

mGetString		MACRO	userVal, display_string

	mDisplayString	display_string				; calls mDisplayString to display user input prompt
	MOV				ECX, 13						; sets character limit for Irving's ReadString
	MOV				EDX,	userVal				; loads the offset address for the temporary storage variable
	CALL			ReadString

ENDM

; ***************************************************************
; Name: mDisplayString
; Macro that displays whatever string array is passed to it as a parameter. Uses Irving's Write String to display string array. 
; receives: Offset address of the string array it is to display. 
; returns:	Nothing.
; preconditions:One parameter passed with offset address of string array to be displayed.
; registers changed: EDX
; ***************************************************************
mDisplayString		MACRO	display_string

	MOV			EDX,	display_string			; loads the offset set for whatever string is to be displayed
	CALL		WriteString

ENDM

.data

intro_string				BYTE	"String Primitives and Macros by Steve Thatcher (ThatChes)",13,10,13,10,13,10,0
description_string_1_1		BYTE	"If you provide 10 signed integers, small enough to fit in 32-bits (-2^32 through 2^31),",13,10,0
description_string_1_2		BYTE	"I will convert them from string to integer, display the list of integers, their sum, and their average",13,10,0
description_string_1_3		BYTE	"then return the result as a string! Neato!",13,10,13,10,0

loop_counter				SDWORD	0
userEntryArray				SDWORD	10 DUP(0)
asciiMidProcessStorage		SDWORD	0
sumStorage					SDWORD	0
intLengthCounter			SDWORD	0
conversionPlaceValue		SDWORD  0
intInProcess				SDWORD	0
is_negative					BYTE	0
userInputString				BYTE	100 DUP(0)			; 10 integer spaces with room for a sign
user_input_prompt			BYTE	"Please enter a signed number: ",0
error_prompt				BYTE	"ERROR: Your number was not signed, too large, empty, or contained invalid characters. Try again!",13,10,0
reverseString				BYTE	11 DUP(0)			; 10 integer spaces with room for a sign

list_of_integers_prompt		BYTE	"Here are the numbers you entered: ",0
sum_prompt					BYTE	"The sum of the integers you entered is: ",0
average_prompt				BYTE	"The rounded (down) average of the integers your entered is: ",0
space_string				BYTE	", ",0


.code
main PROC

	PUSH			OFFSET	intro_string
	PUSH			OFFSET	description_string_1_1
	PUSH			OFFSET	description_string_1_2
	PUSH			OFFSET	description_string_1_3
	CALL			introduction				; calls introduction to display the introduction and prompts

	MOV				EDI, OFFSET userEntryArray  ; Sets address for SDWORD storage array for converted integer strings
	MOV				ECX, 10						; Sets loop counter for 10 user entered integer strings
	PUSH			SDWORD PTR sumStorage		; 56
_ArrayLoop:
	PUSH			asciiMidProcessStorage		; 52
	PUSH			conversionPlaceValue		; 48
	PUSH			intLengthCounter			; 44
	PUSH			intInProcess				; 40
	PUSH			SDWORD PTR is_negative		; 36
	PUSH			OFFSET	error_prompt		; 32
	PUSH			OFFSET	userInputString		; 28
	PUSH			OFFSET	user_input_prompt	; 24
	CALL			ReadVal
	LOOP			_ArrayLoop

	MOV				EAX, SDWORD PTR [EBP - 16]	
	MOV				sumStorage, EAX				; Stores the sum in sumStorage for use in WriteVal

	MOV				ESI, OFFSET userEntryArray	; Move userEntryArray into ESI to prep STOSB
	MOV				ECX, 12						; sets up 12 cycles for loop ()
	PUSH			loop_counter				; 68
_WriteArrayLoop:
	MOV				EAX, 0
	MOV				SDWORD PTR userInputString, EAX
	MOV				SDWORD PTR userInputString + 4, EAX
	MOV				SDWORD PTR userInputString + 8, EAX
	MOV				SDWORD PTR reverseString, EAX
	MOV				SDWORD PTR reverseString + 4, EAX
	MOV				SDWORD PTR reverseString + 8, EAX
	MOV				asciiMidProcessStorage, 0
	MOV				EDI, OFFSET userInputString ; Storage array  ; Points EDI to the memory location of userInputString which will store/display the convert interger to string value
	PUSH			OFFSET	average_prompt		; 64
	PUSH			OFFSET	sum_prompt			; 60 
	PUSH			SDWORD PTR sumStorage		; 56
	PUSH			asciiMidProcessStorage		; 52
	PUSH			OFFSET reverseString		; 48
	PUSH			intLengthCounter			; 44
	PUSH			intInProcess				; 40
	PUSH			SDWORD PTR is_negative		; 36
	PUSH			OFFSET	space_string		; 32
	PUSH			OFFSET	userInputString		; 28
	PUSH			OFFSET	list_of_integers_prompt	; 24
	CALL			WriteVal
	LOOP			_WriteArrayLoop

	Invoke ExitProcess,0						; exit to operating system
main ENDP

; ***************************************************************
; Name: introduction
; Displays programmer, and program, introduction and description.
; receives: addresses of intro_string and all description_strings from stack
; returns: display of intro_string and all discription_strings
; preconditions: intro_string and all description_strings offsets pushed to stack in main.
;				 mDisplayString macro called for all displays of string arrays.
; registers changed: EBP, EDX
; ***************************************************************
introduction PROC USES EDX
	PUSH			EBP				
	MOV				EBP, ESP					; set new base pointer location for frame stack
	mDisplayString	[EBP + 24]
	mDisplayString	[EBP + 20]
	mDisplayString	[EBP + 16]
	mDisplayString	[EBP + 12]
	POP				EBP
	RET				16							; returns to main and resets stack for next procedure
introduction ENDP


; ***************************************************************
; Name: ReadVal
; Called by main in a loop, ReadVal uses both mGetString and mDisplayString to receive integers from the user. 
; It converts each integer string into a signed 32-bit integer, and validates it during conversation.
; If also sums the integers as they are converts into a running total that is called in WriteVal for sum and average. 
; receives: Offset address of array for integer storage, along with pushed variables for temporary storage/calculation. 
; returns:	Array with integer strings converted to signed 32-bit values and sumStorage for future total and average.
; preconditions: Offset addresses of array and the pushed addresses of temporary storage variables. 	 
; registers changed: EAX, EBX, ECX, EDX, EBP
; ***************************************************************
ReadVal PROC  USES EAX EBX ECX EDX
	PUSH			EBP
	MOV				EBP, ESP					; set new base pointer location for frame stack

_newUserEntry:
	mGetString		[EBP + 28], [EBP + 24]		; calls macro for user entry
	CMP				EAX, 0						; Checks for a null entry from user, which is invalid per program requirements
	JE				_outOfRange
	MOV				ESI, [EBP + 28]				; Point ESI to UserInputString OFFSET to prep LODSB

_stringConversion:
	LODSB
	CMP				AL, 43						; checks for plus sign
	JE				_stringConversion
	CMP				AL, 45						; checks for negative sign
	JE				_stringConversionNegative

_stringConversionPositive:
	CMP				AL, 0						; check to see if string is zero
	JE				_isZero
	CMP				AL, 48						; checks lower boundary of zero
	JB				_outOfRange
	CMP				AL, 57						; check upper boundary of nine
	JA				_outOfRange
	SUB				AL, 48						; subtracts 48 from ascii character to convert to integer
	MOV				BYTE PTR [EBP + 52], AL		; stores in ascii holding variable
	MOV				EAX,  [EBP + 40]			; loads integer in process into EAX
	MOV				EBX, 10
	MUL				EBX							; follows ascii to integer conversion algorithm from module 10
	CMP				EDX, 0
	JNE				_outOfRange
	MOV				EBX, [EBP + 52]				; reloads previous mid-conversion value
	ADD				EAX, EBX
	JO				_outOfRange

	MOV				SDWORD PTR [EBP + 40], EAX	; loads integer in process
	LODSB
	LOOP			_stringConversionPositive

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_removeNegativeSign:
	LODSB
_stringConversionNegative:
	CMP				AL, 45						; ascii negative sign
	JE				_removeNegativeSign
	CMP				AL, 0						; if zero
	JE				_isZero
	CMP				AL, 48						; compares to lower boundary zero
	JB				_outOfRange
	CMP				AL, 57						; compares to upper boundary nine
	JA				_outOfRange
	SUB				AL, 48						; converts to integer from ascii
	MOV				EBX, -1
	IMUL			EBX
	MOV				SDWORD PTR [EBP + 52], EAX	; ascii storage variable
	MOV				EAX,  [EBP + 40]			; loads integer in process into EAX
	MOV				EBX, 10
	IMUL			EBX							; converts using algorithm from module 10
	JO				_outOfRange
	MOV				EBX, [EBP + 52]
	ADD				EAX, EBX
	JO				_outOfRange
	MOV				SDWORD PTR [EBP + 40], EAX
	MOV				SDWORD PTR [EDI], EAX		; Store value in array
	MOV				EAX, 0
	LODSB								
	LOOP			_stringConversionNegative

_outOfRange:
	mDisplayString	[EBP + 32]					; display error prompt using mDisplayString
	CALL			CRLF
	MOV				SDWORD PTR [EBP + 40], 0	; Resets integer storage variable for next value
	MOV				SDWORD PTR [EBP + 52], 0	; resets ascii temp variable for next value
	JMP				_newUserEntry

_isZero:
	MOV				EAX, SDWORD PTR [EBP + 40]
	MOV				SDWORD PTR [EBP + 40], 0
	MOV				SDWORD PTR [EBP + 52], 0

	MOV				SDWORD PTR [EDI], EAX		; Store value in array
	ADD				SDWORD PTR [EBP + 56], EAX  ; store value in sumStorage
	ADD				EDI, 4						; moves to next value in string array
	MOV				SDWORD PTR [EBP + 40], 0
	POP				EBP
	RET				32							; returns to main and resets stack for next procedure

ReadVal ENDP



; ***************************************************************
; Name: WriteVal
; Called by main in a loop, WriteVal uses mDisplayString to display the integers from the user. 
; It converts each signed 32-bit integer into an integer string, which it then displays.
; After displaying the 10 integer strings it jumps to convert the sumStorage value into an integer string and displays it. 
; It then calculates a rounded down average fro sumStorage by dividing by 10, then converts the result into and integer string and displays it. 
; receives: Offset address of array for integer storage, along with pushed variables for temporary storage/calculation, and sumStorage. 
; returns:	A display of the integers as integer strings using mDisplayString, along with sum and average.
; preconditions: Offset addresses of array and the pushed addresses of temporary storage variables, along with sumStorage. 	 
; registers changed: EAX, EBX, ECX, EDX, EBP
; ***************************************************************
WriteVal PROC   USES EAX EBX ECX EDX
	PUSH			EBP
	MOV				EBP, ESP					; set new base pointer location for frame stack


	CMP				BYTE PTR [EBP + 68], 0		; compares main loop count to 0 to print list of int prompt one time 
	JNE				_skipListOfIntPromptPrint
	CALL			CRLF
	mDisplayString	SDWORD PTR [EBP + 24]		; prints list of integers prompts

_skipListOfIntPromptPrint:
	CMP				SDWORD PTR [EBP + 68], 10	; if all 10 integer strings have been converted and displayed, jump to sum
	JE				_SumStart
	CMP				SDWORD PTR [EBP + 68], 11	; if all 10 integer strings have been converted and displayed, jump to average
	JE				_averageStart
	MOV				SDWORD PTR [EBP + 36], 0	; Reset negative variable for new integer from array

	PUSHAD
	MOV				EDX, 0
	MOV				EAX, SDWORD PTR [ESI]		; loads first integer from SDWORD array into EAX
	CMP				EAX, 0
	JE				_isPositive					; if equal to zero, jumps to positive section
	JNS				_isPositive					; if not negative, jumps to positive section
	MOV				SDWORD PTR [EBP + 36], 1	; Sets is negative to 1 for negative


_isPositive:									; determines the number of digits in a positive integer and stores in intLengthCounter
	MOV				EBX, 10						
	MOV				ECX, 0						 
_jumpHere: 									 
	CDQ
	IDIV			EBX							 
	INC				ECX							 
	CMP				EAX, 0						 
	JNE				_jumpHere					 
	MOV				[EBP + 44], ECX			 

	POPAD

	MOV				EAX, [ESI]					; reloads integer from array into EAX
	CMP				SDWORD PTR [EBP + 36], 1	; checks for negative status
	JNE				_stillPositive
	MOV				EBX, -1
	IMUL			EBX							; converts negative number to positive

_stillPositive:
	MOV				ECX, [EBP + 44]				; loads integer length into ECX for conversion loop

_intToStringConversion:
	MOV				EBX, 10
	MOV				EDX, 0
	IDIV			EBX							; divide by 10 to get last value in current working integer
	CMP				EAX, 0
	JNE				_skipZero					; if zero, drop out of loop by setting ECX to zero
	MOV				ECX, 0

_skipZero:
	MOV				SDWORD PTR [EBP + 52], EAX	; store in mid process ascii val
	MOV				EAX, EDX
	ADD				EAX, 48
	STOSB
	MOV				EAX, SDWORD PTR [EBP + 52]
	CMP				ECX, 0
	JE				_displayValue				; if loop has reached zero in EAX, display value
	LOOP			_intToStringConversion		; loop if more division is needed to reach zero in EAX

_displayValue:
	PUSH			ECX
	PUSH			ESI
	PUSH			EDI
	PUSH			EAX
	MOV				ESI, [EBP + 28]				; points ESI to converted integer
	ADD				ESI, [EBP + 44]				; points ESI to end of converted integer
	DEC				ESI
	MOV				EDI, [EBP + 48]				; temporary storage var
	MOV				ECX, [EBP + 44]				; sets counter loop to number of digits in integer

_reverseStringForDisplay:
    STD											; sets direction flag
	LODSB
	CMP				SDWORD PTR [EBP + 36], 1
	JNE				_reallyPositive				; skips storing negative sign if positive
	MOV				BYTE PTR [EDI], 45			; stores negative sign in EDI
	MOV				SDWORD PTR [EBP + 36], 0
	ADD				EDI, 1						; increments to next character in string array after negative sign

_reallyPositive:
	
	CLD											; clears direction falg
	STOSB										; stores in string array
	LOOP			_reverseStringForDisplay
	POP				EAX
	POP				EDI
	POP				ESI
	POP				ECX
	
	mDisplayString	[EBP + 48]					; displays converts integer string
	mDisplayString	[EBP + 32]					; space string between integers


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ADD				SDWORD PTR [EBP + 68], 1		; Increment main cycle counter

	JMP				_notTimeToAvgAndSum				; skip sum and average if still processing the ten integers

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_sumStart:
	
	CALL			CRLF
	MOV				EAX, SDWORD PTR [EBP + 56]		; loads the sum of the integers calculated in ReadVal into EAX
	
	CALL			CRLF
	mDisplayString	[EBP + 60]						; displays sum prompt


	JMP				_sumAndAveragePrinting			; jumps to print sum and loop before calculating average and printing

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	AVERAGE CALCULATION

_averageStart:
	MOV				EAX, SDWORD PTR [EBP + 56]		; loads the sum of the integers calculated in ReadVal into EAX
	CMP				EAX, 0
	JNS				_negativeIntToAvg3				; jumps if sum is positive
	NEG				EAX								; converts value to positive
	MOV				EDX, 0
	MOV				EBX, 10
	IDIV			EBX								; divides by 10 to get average	
	NEG				EAX								; converts back from positive to negative	
	JMP				_readyToPrint3

_negativeIntToAvg3:
	MOV				EDX, 0
	MOV				EBX, 10							; divides by 10 to get average
	IDIV			EBX

_readyToPrint3:
	mDisplayString	[EBP + 64]						; displays average prompts


	MOV				SDWORD PTR [EBP + 56], EAX		; Save Average into for printing

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Printing for the sum

_sumAndAveragePrinting:
	
	MOV				SDWORD PTR [EBP + 36], 0		; Resets negative tracking variable

	PUSHAD
	MOV				EDX, 0
	CMP				EAX, 0	
	JE				_isPositive2				; determines if the average value is 0
	JNS				_isPositive2				; determins if the average value is negative

	MOV				SDWORD PTR [EBP + 36], 1	; Sets is negative
	NEG				EAX							; converts from negative to positive


_isPositive2:									; calculates number of digits in average sum integer and stores in intLengthCounter
	MOV				EBX, 10						 
	MOV				ECX, 0						 
_jumpHere2: 								 
	MOV				EDX, 0						 
	IDIV			EBX							 
	INC				ECX							 
	CMP				EAX, 0					 
	JNE				_jumpHere2					 
	MOV				[EBP + 44], ECX				 


	POPAD

	MOV				EAX, SDWORD PTR [EBP + 56]	; moves integer sum into EAX
		
	CMP				SDWORD PTR [EBP + 36], 1	; checks for negative status
	JNE				_stillPositive2
	NEG				EAX							; converts from positive to negative

_stillPositive2:

	MOV				ECX, [EBP + 44]				; Moves length of integer, minus negative sign, into loop counter ECX

_intToStringConversion2:

	MOV				EBX, 10
	MOV				EDX, 0
	IDIV			EBX							; dividing by 10 per module 10 algorithm
	CMP				EAX, 0
	JNE				_skipZero2					; if zero, sets ECX to 0 to exit loop
	MOV				ECX, 0

_skipZero2:
	MOV				SDWORD PTR [EBP + 52], EAX	; moves into temp holding varible
	MOV				EAX, EDX
	ADD				EAX, 48						; converts to ascii character 
	STOSB
	MOV				EAX, SDWORD PTR [EBP + 52]	; reload mid process var
	
	CMP				ECX, 0						
	JE				_displayValue2				; if fully converted, move to display
	LOOP			_intToStringConversion2		; otherwise loop

_displayValue2:
	
	PUSH			ECX
	PUSH			ESI
	PUSH			EDI
	PUSH			EAX
	MOV				ESI, [EBP + 28]				; points ESI to converted integer
	ADD				ESI, [EBP + 44]				; points ESI to end of converted integer
	DEC				ESI
	MOV				EDI, [EBP + 48]				; temporary storage var
	MOV				ECX, [EBP + 44]				; sets counter loop to number of digits in integer
_reverseStringForDisplay2:
    STD
	LODSB

	
	CMP				SDWORD PTR [EBP + 36], 1
	JNE				_reallyPositive2
	MOV				BYTE PTR [EDI], 45			; stores negative sign
	MOV				SDWORD PTR [EBP + 36], 0
	ADD				EDI, 1						; increments EDI after negative sign


_reallyPositive2:
	
	CLD
	STOSB										; stores converted value
	LOOP			_reverseStringForDisplay2
	POP				EAX
	POP				EDI
	POP				ESI
	POP				ECX
	

	mDisplayString	[EBP + 48]					; displays the completed integer string

	CALL			CRLF
	ADD				SDWORD PTR [EBP + 68], 1    ; Increment cycle counter to end main loop
	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_notTimeToAvgAndSum:
	
	LODSD										; loads next array value for processing
	POP				EBP
	RET				44							; returns to main and resets stack for next procedure


WriteVal ENDP

END main

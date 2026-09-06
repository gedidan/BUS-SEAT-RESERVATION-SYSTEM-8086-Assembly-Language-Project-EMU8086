;================================================================
; BUS SEAT RESERVATION SYSTEM - LINKED BUS VERSION
; 8086 Assembly Language Project - EMU8086 / MASM syntax
;
; 4 buses, each with 20 seats:
;   Bus 1 = Adama       = 150 Birr
;   Bus 2 = Hawassa     = 350 Birr
;   Bus 3 = Bishoftu    = 120 Birr
;   Bus 4 = Bahir Dar   = 600 Birr
;
; Reservation flow:
;   Destination -> Bus -> Seat -> Confirmation
;   Example: Adama + Seat 1 = ADAMA-1, Bus 1, 150 Birr
;
; Features:
;   1. View Bus Seats
;   2. Reserve Seat
;   3. Cancel Reservation
;   4. Available Seats
;   5. Booking Summary
;   6. Exit
;================================================================

.MODEL SMALL
.STACK 100H

.DATA

TITLE_MSG DB 13,10
          DB '================================================',13,10
          DB '          BUS SEAT RESERVATION SYSTEM',13,10
          DB '================================================',13,10,'$'

MENU_MSG DB 13,10
         DB '1. View Bus Seats',13,10
         DB '2. Reserve Seat',13,10
         DB '3. Cancel Reservation',13,10
         DB '4. Available Seats',13,10
         DB '5. Booking Summary',13,10
         DB '6. Exit',13,10
         DB '================================================',13,10
         DB 'Enter your choice: $'

INVALID_CHOICE_MSG DB 13,10,'Invalid choice! Please select 1-6.',13,10,'$'
PRESS_KEY_MSG DB 13,10,'Press any key to return to the main menu...$'
EXIT_MSG DB 13,10,'Thank you for using the Bus Reservation System!',13,10
         DB 'Program terminated.',13,10,'$'
NEWLINE DB 13,10,'$'

;----- Bus / destination menu -----
DEST_MENU_MSG DB 13,10
              DB '================ BUS DESTINATIONS ================',13,10
              DB '1. Bus 1 - Adama       - 150 Birr',13,10
              DB '2. Bus 2 - Hawassa     - 350 Birr',13,10
              DB '3. Bus 3 - Bishoftu    - 120 Birr',13,10
              DB '4. Bus 4 - Bahir Dar   - 600 Birr',13,10
              DB '==================================================',13,10
              DB 'Choose destination: $'
INVALID_DEST_MSG DB 13,10,'Invalid destination choice! Please select 1-4.',13,10,'$'
BUS_SELECTED_MSG DB 13,10,'Selected: $'
BUS_LABEL_MSG DB 'Bus $'
PRICE_LABEL_MSG DB 'Price: $'
SEAT_LABEL_MSG DB 'Seat $'
AVAILABLE_LABEL_MSG DB ' [Available]$'
RESERVED_LABEL_MSG DB ' [Reserved]$'
VIEW_HEADER_MSG DB 13,10,'================ BUS SEATS ================',13,10,'$'

;----- Reservation messages -----
ENTER_SEAT_MSG DB 13,10,'Enter seat number (1-20): $'
INVALID_SEAT_MSG DB 13,10,'Invalid seat number! Enter a number from 1 to 20.',13,10,'$'
SEAT_AVAILABLE_MSG DB 13,10,'Seat $'
SEAT_AVAILABLE_MSG2 DB ' is available. Reserve it? (Y/N): $'
RESERVE_CANCELLED_MSG DB 13,10,'Reservation cancelled by user.',13,10,'$'
SEAT_TAKEN_MSG DB 13,10,'Sorry! Seat $'
SEAT_TAKEN_MSG2 DB ' is already reserved on this bus.',13,10,'$'
BUS_FULL_MSG DB 13,10,'Sorry! This bus is full.',13,10,'$'
RESERVE_SUCCESS_MSG DB 13,10,'Reservation successful!',13,10,'$'
BUS_ID_LABEL DB 'Bus ID        : Bus $'
DEST_LABEL_MSG DB 'Destination   : $'
SEAT_INFO_LABEL DB 'Seat Number   : $'
BOOKING_ID_LABEL DB 'Booking ID    : $'
FARE_INFO_LABEL DB 'Price         : $'
BIRR_MSG DB ' Birr$'

;----- Cancellation messages -----
ENTER_CANCEL_MSG DB 13,10,'Enter seat number to cancel (1-20): $'
CANCEL_SUCCESS_MSG DB 13,10,'Reservation cancelled successfully.',13,10,'$'
CANCEL_NOTRES_MSG DB 13,10,'That seat is not currently reserved.',13,10,'$'

;----- Available seat messages -----
AVAIL_HEADER_MSG DB 13,10,'================ AVAILABLE SEATS ================',13,10,'$'
TOTAL_SEATS_MSG DB 'Total Seats     : $'
RESERVED_SEATS_MSG DB 'Reserved Seats  : $'
AVAILABLE_SEATS_MSG DB 'Available Seats : $'
DIVIDER_MSG DB '==================================================',13,10,'$'

;----- Summary messages -----
SUMMARY_HEADER_MSG DB 13,10
                   DB '==================================================',13,10
                   DB '                 BOOKING SUMMARY',13,10
                   DB '==================================================',13,10,'$'
SUMMARY_LINE_MSG DB '--------------------------------------------------',13,10,'$'
NO_RESERVATION_MSG DB 'No reservations have been made yet.',13,10,'$'
SUMMARY_BUS_MSG DB 'Bus: $'
SUMMARY_DEST_MSG DB ' | Destination: $'
SUMMARY_SEAT_MSG DB ' | Seat: $'
SUMMARY_PRICE_MSG DB ' | Price: $'
SUMMARY_ID_MSG DB ' | ID: $'
TOTAL_RESERVATIONS_MSG DB 13,10,'Total Reservations: $'
TOTAL_FARE_MSG DB 'Total Fare        : $'

;----- Destination names -----
DEST1_NAME DB 'Adama$'
DEST2_NAME DB 'Hawassa$'
DEST3_NAME DB 'Bishoftu$'
DEST4_NAME DB 'Bahir Dar$'
ID1_NAME DB 'ADAMA-$'
ID2_NAME DB 'HAWASSA-$'
ID3_NAME DB 'BISHOFTU-$'
ID4_NAME DB 'BAHIRDAR-$'

;----- Four separate 20-seat bus arrays -----
; 0 = Available, 1 = Reserved
ADAMA_SEATS DB 20 DUP(0)
HAWASSA_SEATS DB 20 DUP(0)
BISHOFTU_SEATS DB 20 DUP(0)
BAHIRDAR_SEATS DB 20 DUP(0)

TOTAL_SEATS DB 20

; Current selection
SELECTED_BUS DB 0       ; 1=Adama, 2=Hawassa, 3=Bishoftu, 4=Bahir Dar
SELECTED_PRICE DW 0

; Summary totals
RESERVATION_TOTAL DW 0
FARE_TOTAL DW 0

.CODE

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

MAIN_LOOP:
    CALL DISPLAY_MENU

    MOV AH, 01H
    INT 21H
    CALL NEW_LINE

    CMP AL, '1'
    JE M_VIEW
    CMP AL, '2'
    JE M_RESERVE
    CMP AL, '3'
    JE M_CANCEL
    CMP AL, '4'
    JE M_AVAILABLE
    CMP AL, '5'
    JE M_SUMMARY
    CMP AL, '6'
    JE M_EXIT

    LEA DX, INVALID_CHOICE_MSG
    MOV AH, 09H
    INT 21H
    JMP M_CONTINUE

M_VIEW:
    CALL VIEW_SEATS
    JMP M_CONTINUE
M_RESERVE:
    CALL RESERVE_SEAT
    JMP M_CONTINUE
M_CANCEL:
    CALL CANCEL_SEAT
    JMP M_CONTINUE
M_AVAILABLE:
    CALL AVAILABLE_SEATS
    JMP M_CONTINUE
M_SUMMARY:
    CALL BOOKING_SUMMARY
    JMP M_CONTINUE

M_CONTINUE:
    LEA DX, PRESS_KEY_MSG
    MOV AH, 09H
    INT 21H
    MOV AH, 01H
    INT 21H
    CALL NEW_LINE
    JMP MAIN_LOOP

M_EXIT:
    LEA DX, EXIT_MSG
    MOV AH, 09H
    INT 21H
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;================================================================
; DISPLAY_MENU
;================================================================
DISPLAY_MENU PROC
    PUSH AX
    PUSH DX
    LEA DX, TITLE_MSG
    MOV AH, 09H
    INT 21H
    LEA DX, MENU_MSG
    MOV AH, 09H
    INT 21H
    POP DX
    POP AX
    RET
DISPLAY_MENU ENDP

;================================================================
; SELECT_DESTINATION
; Reads destination choice and sets SELECTED_BUS and SELECTED_PRICE.
; Carry flag = 1 if invalid, 0 if valid.
;================================================================
SELECT_DESTINATION PROC
    PUSH AX
    PUSH DX

    LEA DX, DEST_MENU_MSG
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H
    CALL NEW_LINE

    CMP AL, '1'
    JE SD_ADAMA
    CMP AL, '2'
    JE SD_HAWASSA
    CMP AL, '3'
    JE SD_BISHOFTU
    CMP AL, '4'
    JE SD_BAHIRDAR

    LEA DX, INVALID_DEST_MSG
    MOV AH, 09H
    INT 21H
    STC
    JMP SD_DONE

SD_ADAMA:
    MOV SELECTED_BUS, 1
    MOV SELECTED_PRICE, 150
    CLC
    JMP SD_DONE
SD_HAWASSA:
    MOV SELECTED_BUS, 2
    MOV SELECTED_PRICE, 350
    CLC
    JMP SD_DONE
SD_BISHOFTU:
    MOV SELECTED_BUS, 3
    MOV SELECTED_PRICE, 120
    CLC
    JMP SD_DONE
SD_BAHIRDAR:
    MOV SELECTED_BUS, 4
    MOV SELECTED_PRICE, 600
    CLC

SD_DONE:
    POP DX
    POP AX
    RET
SELECT_DESTINATION ENDP

;================================================================
; PRINT_SELECTED_INFO
; Prints selected bus and destination/price.
;================================================================
PRINT_SELECTED_INFO PROC
    PUSH AX
    PUSH DX

    LEA DX, BUS_SELECTED_MSG
    MOV AH, 09H
    INT 21H
    MOV AL, SELECTED_BUS
    MOV AH, 0
    CALL PRINT_NUMBER
    CALL PRINT_BUS_NAME
    CALL NEW_LINE

    LEA DX, DEST_LABEL_MSG
    MOV AH, 09H
    INT 21H
    CALL PRINT_DEST_NAME
    CALL NEW_LINE

    LEA DX, PRICE_LABEL_MSG
    MOV AH, 09H
    INT 21H
    MOV AX, SELECTED_PRICE
    CALL PRINT_NUMBER
    LEA DX, BIRR_MSG
    MOV AH, 09H
    INT 21H
    CALL NEW_LINE

    POP DX
    POP AX
    RET
PRINT_SELECTED_INFO ENDP

;================================================================
; VIEW_SEATS
; Select destination first, then display its 20 seats.
;================================================================
VIEW_SEATS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CALL SELECT_DESTINATION
    JC VS_DONE
    CALL PRINT_SELECTED_INFO

    LEA DX, VIEW_HEADER_MSG
    MOV AH, 09H
    INT 21H

    MOV SI, 0
    MOV CX, 20
    MOV BL, 0

VS_LOOP:
    LEA DX, SEAT_LABEL_MSG
    MOV AH, 09H
    INT 21H
    MOV AX, SI
    INC AX
    CALL PRINT_NUMBER

    CMP SELECTED_BUS, 1
    JE VS_ADAMA
    CMP SELECTED_BUS, 2
    JE VS_HAWASSA
    CMP SELECTED_BUS, 3
    JE VS_BISHOFTU
    JMP VS_BAHIRDAR

VS_ADAMA:
    CMP ADAMA_SEATS[SI], 0
    JE VS_AVAILABLE
    JMP VS_RESERVED
VS_HAWASSA:
    CMP HAWASSA_SEATS[SI], 0
    JE VS_AVAILABLE
    JMP VS_RESERVED
VS_BISHOFTU:
    CMP BISHOFTU_SEATS[SI], 0
    JE VS_AVAILABLE
    JMP VS_RESERVED
VS_BAHIRDAR:
    CMP BAHIRDAR_SEATS[SI], 0
    JE VS_AVAILABLE

VS_RESERVED:
    LEA DX, RESERVED_LABEL_MSG
    MOV AH, 09H
    INT 21H
    JMP VS_NEXT
VS_AVAILABLE:
    LEA DX, AVAILABLE_LABEL_MSG
    MOV AH, 09H
    INT 21H
VS_NEXT:
    CALL NEW_LINE
    INC BL
    CMP BL, 5
    JL VS_NO_BLANK
    CALL NEW_LINE
    MOV BL, 0
VS_NO_BLANK:
    INC SI
    LOOP VS_LOOP

VS_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
VIEW_SEATS ENDP

;================================================================
; RESERVE_SEAT
; Destination first -> bus identified -> seat selected -> reserve.
; Automatically creates booking ID and calculates fixed fare.
;================================================================
RESERVE_SEAT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CALL SELECT_DESTINATION
    JC RS_DONE
    CALL PRINT_SELECTED_INFO

    ; Check whether selected bus has an available seat.
    CALL CHECK_BUS_AVAILABLE
    CMP AL, 0
    JNE RS_NOT_FULL
    LEA DX, BUS_FULL_MSG
    MOV AH, 09H
    INT 21H
    JMP RS_DONE

RS_NOT_FULL:
    LEA DX, ENTER_SEAT_MSG
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER

    CMP AX, 1
    JL RS_INVALID
    CMP AX, 20
    JG RS_INVALID

    DEC AX
    MOV SI, AX

    ; Check selected bus array.
    CMP SELECTED_BUS, 1
    JE RS_CHECK_ADAMA
    CMP SELECTED_BUS, 2
    JE RS_CHECK_HAWASSA
    CMP SELECTED_BUS, 3
    JE RS_CHECK_BISHOFTU
    JMP RS_CHECK_BAHIRDAR

RS_CHECK_ADAMA:
    CMP ADAMA_SEATS[SI], 1
    JE RS_TAKEN
    JMP RS_CONFIRM_MSG
RS_CHECK_HAWASSA:
    CMP HAWASSA_SEATS[SI], 1
    JE RS_TAKEN
    JMP RS_CONFIRM_MSG
RS_CHECK_BISHOFTU:
    CMP BISHOFTU_SEATS[SI], 1
    JE RS_TAKEN
    JMP RS_CONFIRM_MSG
RS_CHECK_BAHIRDAR:
    CMP BAHIRDAR_SEATS[SI], 1
    JE RS_TAKEN

RS_CONFIRM_MSG:
    LEA DX, SEAT_AVAILABLE_MSG
    MOV AH, 09H
    INT 21H
    MOV AX, SI
    INC AX
    CALL PRINT_NUMBER
    LEA DX, SEAT_AVAILABLE_MSG2
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H
    CALL NEW_LINE
    CMP AL, 'Y'
    JE RS_CONFIRM
    CMP AL, 'y'
    JE RS_CONFIRM

    LEA DX, RESERVE_CANCELLED_MSG
    MOV AH, 09H
    INT 21H
    JMP RS_DONE

RS_CONFIRM:
    CMP SELECTED_BUS, 1
    JE RS_SET_ADAMA
    CMP SELECTED_BUS, 2
    JE RS_SET_HAWASSA
    CMP SELECTED_BUS, 3
    JE RS_SET_BISHOFTU
    JMP RS_SET_BAHIRDAR

RS_SET_ADAMA:
    MOV ADAMA_SEATS[SI], 1
    JMP RS_SAVED
RS_SET_HAWASSA:
    MOV HAWASSA_SEATS[SI], 1
    JMP RS_SAVED
RS_SET_BISHOFTU:
    MOV BISHOFTU_SEATS[SI], 1
    JMP RS_SAVED
RS_SET_BAHIRDAR:
    MOV BAHIRDAR_SEATS[SI], 1

RS_SAVED:
    INC RESERVATION_TOTAL
    MOV AX, RESERVATION_TOTAL
    ADD AX, 0
    MOV AX, SELECTED_PRICE
    ADD FARE_TOTAL, AX

    LEA DX, RESERVE_SUCCESS_MSG
    MOV AH, 09H
    INT 21H
    CALL PRINT_BOOKING_DETAILS
    JMP RS_DONE

RS_TAKEN:
    LEA DX, SEAT_TAKEN_MSG
    MOV AH, 09H
    INT 21H
    MOV AX, SI
    INC AX
    CALL PRINT_NUMBER
    LEA DX, SEAT_TAKEN_MSG2
    MOV AH, 09H
    INT 21H
    JMP RS_DONE

RS_INVALID:
    LEA DX, INVALID_SEAT_MSG
    MOV AH, 09H
    INT 21H

RS_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
RESERVE_SEAT ENDP

;================================================================
; CHECK_BUS_AVAILABLE
; AL = 1 if any seat is available, AL = 0 if full.
;================================================================
CHECK_BUS_AVAILABLE PROC
    PUSH BX
    PUSH CX
    PUSH SI

    MOV SI, 0
    MOV CX, 20
    MOV AL, 0

CBA_LOOP:
    CMP SELECTED_BUS, 1
    JE CBA_A
    CMP SELECTED_BUS, 2
    JE CBA_H
    CMP SELECTED_BUS, 3
    JE CBA_B
    JMP CBA_D
CBA_A:
    CMP ADAMA_SEATS[SI], 0
    JE CBA_FOUND
    JMP CBA_NEXT
CBA_H:
    CMP HAWASSA_SEATS[SI], 0
    JE CBA_FOUND
    JMP CBA_NEXT
CBA_B:
    CMP BISHOFTU_SEATS[SI], 0
    JE CBA_FOUND
    JMP CBA_NEXT
CBA_D:
    CMP BAHIRDAR_SEATS[SI], 0
    JE CBA_FOUND
CBA_NEXT:
    INC SI
    LOOP CBA_LOOP
    JMP CBA_DONE
CBA_FOUND:
    MOV AL, 1
CBA_DONE:
    POP SI
    POP CX
    POP BX
    RET
CHECK_BUS_AVAILABLE ENDP

;================================================================
; CANCEL_SEAT
; Destination first -> seat -> change 1 back to 0.
;================================================================
CANCEL_SEAT PROC
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI

    CALL SELECT_DESTINATION
    JC CS_DONE
    CALL PRINT_SELECTED_INFO

    LEA DX, ENTER_CANCEL_MSG
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER

    CMP AX, 1
    JL CS_INVALID
    CMP AX, 20
    JG CS_INVALID

    DEC AX
    MOV SI, AX

    CMP SELECTED_BUS, 1
    JE CS_ADAMA
    CMP SELECTED_BUS, 2
    JE CS_HAWASSA
    CMP SELECTED_BUS, 3
    JE CS_BISHOFTU
    JMP CS_BAHIRDAR

CS_ADAMA:
    CMP ADAMA_SEATS[SI], 0
    JE CS_NOT_RESERVED
    MOV ADAMA_SEATS[SI], 0
    JMP CS_SUCCESS
CS_HAWASSA:
    CMP HAWASSA_SEATS[SI], 0
    JE CS_NOT_RESERVED
    MOV HAWASSA_SEATS[SI], 0
    JMP CS_SUCCESS
CS_BISHOFTU:
    CMP BISHOFTU_SEATS[SI], 0
    JE CS_NOT_RESERVED
    MOV BISHOFTU_SEATS[SI], 0
    JMP CS_SUCCESS
CS_BAHIRDAR:
    CMP BAHIRDAR_SEATS[SI], 0
    JE CS_NOT_RESERVED
    MOV BAHIRDAR_SEATS[SI], 0

CS_SUCCESS:
    DEC RESERVATION_TOTAL
    MOV AX, SELECTED_PRICE
    SUB FARE_TOTAL, AX
    LEA DX, CANCEL_SUCCESS_MSG
    MOV AH, 09H
    INT 21H
    JMP CS_DONE

CS_NOT_RESERVED:
    LEA DX, CANCEL_NOTRES_MSG
    MOV AH, 09H
    INT 21H
    JMP CS_DONE

CS_INVALID:
    LEA DX, INVALID_SEAT_MSG
    MOV AH, 09H
    INT 21H

CS_DONE:
    POP SI
    POP DX
    POP BX
    POP AX
    RET
CANCEL_SEAT ENDP

;================================================================
; AVAILABLE_SEATS
; Shows totals for the selected bus.
;================================================================
AVAILABLE_SEATS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CALL SELECT_DESTINATION
    JC AS_DONE
    CALL PRINT_SELECTED_INFO

    MOV SI, 0
    MOV CX, 20
    MOV BL, 0

AS_LOOP:
    CMP SELECTED_BUS, 1
    JE AS_A
    CMP SELECTED_BUS, 2
    JE AS_H
    CMP SELECTED_BUS, 3
    JE AS_B
    JMP AS_D
AS_A:
    CMP ADAMA_SEATS[SI], 0
    JE AS_INC
    JMP AS_NEXT
AS_H:
    CMP HAWASSA_SEATS[SI], 0
    JE AS_INC
    JMP AS_NEXT
AS_B:
    CMP BISHOFTU_SEATS[SI], 0
    JE AS_INC
    JMP AS_NEXT
AS_D:
    CMP BAHIRDAR_SEATS[SI], 0
    JE AS_INC
    JMP AS_NEXT
AS_INC:
    INC BL
AS_NEXT:
    INC SI
    LOOP AS_LOOP

    LEA DX, AVAIL_HEADER_MSG
    MOV AH, 09H
    INT 21H
    LEA DX, TOTAL_SEATS_MSG
    MOV AH, 09H
    INT 21H
    MOV AL, TOTAL_SEATS
    MOV AH, 0
    CALL PRINT_NUMBER
    CALL NEW_LINE

    LEA DX, AVAILABLE_SEATS_MSG
    MOV AH, 09H
    INT 21H
    MOV AL, BL
    MOV AH, 0
    CALL PRINT_NUMBER
    CALL NEW_LINE

    LEA DX, RESERVED_SEATS_MSG
    MOV AH, 09H
    INT 21H
    MOV AL, TOTAL_SEATS
    MOV AH, 0
    SUB AL, BL
    MOV AH, 0
    CALL PRINT_NUMBER
    CALL NEW_LINE

    LEA DX, DIVIDER_MSG
    MOV AH, 09H
    INT 21H

AS_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
AVAILABLE_SEATS ENDP

;================================================================
; BOOKING_SUMMARY
; Scans all four arrays and prints every reservation with:
; Bus ID, destination, seat, price, booking ID.
;================================================================
BOOKING_SUMMARY PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA DX, SUMMARY_HEADER_MSG
    MOV AH, 09H
    INT 21H

    CMP RESERVATION_TOTAL, 0
    JNE BS_HAS
    LEA DX, NO_RESERVATION_MSG
    MOV AH, 09H
    INT 21H
    JMP BS_TOTALS

BS_HAS:
    ; Bus 1 - Adama
    MOV SELECTED_BUS, 1
    MOV SELECTED_PRICE, 150
    MOV SI, 0
    MOV CX, 20
BS_A_LOOP:
    CMP ADAMA_SEATS[SI], 1
    JNE BS_A_NEXT
    CALL PRINT_SUMMARY_RECORD
BS_A_NEXT:
    INC SI
    LOOP BS_A_LOOP

    ; Bus 2 - Hawassa
    MOV SELECTED_BUS, 2
    MOV SELECTED_PRICE, 350
    MOV SI, 0
    MOV CX, 20
BS_H_LOOP:
    CMP HAWASSA_SEATS[SI], 1
    JNE BS_H_NEXT
    CALL PRINT_SUMMARY_RECORD
BS_H_NEXT:
    INC SI
    LOOP BS_H_LOOP

    ; Bus 3 - Bishoftu
    MOV SELECTED_BUS, 3
    MOV SELECTED_PRICE, 120
    MOV SI, 0
    MOV CX, 20
BS_B_LOOP:
    CMP BISHOFTU_SEATS[SI], 1
    JNE BS_B_NEXT
    CALL PRINT_SUMMARY_RECORD
BS_B_NEXT:
    INC SI
    LOOP BS_B_LOOP

    ; Bus 4 - Bahir Dar
    MOV SELECTED_BUS, 4
    MOV SELECTED_PRICE, 600
    MOV SI, 0
    MOV CX, 20
BS_D_LOOP:
    CMP BAHIRDAR_SEATS[SI], 1
    JNE BS_D_NEXT
    CALL PRINT_SUMMARY_RECORD
BS_D_NEXT:
    INC SI
    LOOP BS_D_LOOP

BS_TOTALS:
    LEA DX, SUMMARY_LINE_MSG
    MOV AH, 09H
    INT 21H
    LEA DX, TOTAL_RESERVATIONS_MSG
    MOV AH, 09H
    INT 21H
    MOV AX, RESERVATION_TOTAL
    CALL PRINT_NUMBER
    CALL NEW_LINE

    LEA DX, TOTAL_FARE_MSG
    MOV AH, 09H
    INT 21H
    MOV AX, FARE_TOTAL
    CALL PRINT_NUMBER
    LEA DX, BIRR_MSG
    MOV AH, 09H
    INT 21H
    CALL NEW_LINE

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
BOOKING_SUMMARY ENDP

;================================================================
; PRINT_SUMMARY_RECORD
; SI = seat array index, SELECTED_BUS/PRICE identify the bus.
;================================================================
PRINT_SUMMARY_RECORD PROC
    PUSH AX
    PUSH DX

    LEA DX, SUMMARY_BUS_MSG
    MOV AH, 09H
    INT 21H
    MOV AL, SELECTED_BUS
    MOV AH, 0
    CALL PRINT_NUMBER

    LEA DX, SUMMARY_DEST_MSG
    MOV AH, 09H
    INT 21H
    CALL PRINT_DEST_NAME

    LEA DX, SUMMARY_SEAT_MSG
    MOV AH, 09H
    INT 21H
    MOV AX, SI
    INC AX
    CALL PRINT_NUMBER

    LEA DX, SUMMARY_PRICE_MSG
    MOV AH, 09H
    INT 21H
    MOV AX, SELECTED_PRICE
    CALL PRINT_NUMBER
    LEA DX, BIRR_MSG
    MOV AH, 09H
    INT 21H

    LEA DX, SUMMARY_ID_MSG
    MOV AH, 09H
    INT 21H
    CALL PRINT_BOOKING_ID
    CALL NEW_LINE

    POP DX
    POP AX
    RET
PRINT_SUMMARY_RECORD ENDP

;================================================================
; PRINT_BOOKING_DETAILS
; Prints information for the newly created reservation.
; SI = reserved seat index.
;================================================================
PRINT_BOOKING_DETAILS PROC
    PUSH AX
    PUSH DX

    LEA DX, BUS_ID_LABEL
    MOV AH, 09H
    INT 21H
    MOV AL, SELECTED_BUS
    MOV AH, 0
    CALL PRINT_NUMBER
    CALL NEW_LINE

    LEA DX, DEST_LABEL_MSG
    MOV AH, 09H
    INT 21H
    CALL PRINT_DEST_NAME
    CALL NEW_LINE

    LEA DX, SEAT_INFO_LABEL
    MOV AH, 09H
    INT 21H
    MOV AX, SI
    INC AX
    CALL PRINT_NUMBER
    CALL NEW_LINE

    LEA DX, BOOKING_ID_LABEL
    MOV AH, 09H
    INT 21H
    CALL PRINT_BOOKING_ID
    CALL NEW_LINE

    LEA DX, FARE_INFO_LABEL
    MOV AH, 09H
    INT 21H
    MOV AX, SELECTED_PRICE
    CALL PRINT_NUMBER
    LEA DX, BIRR_MSG
    MOV AH, 09H
    INT 21H
    CALL NEW_LINE

    POP DX
    POP AX
    RET
PRINT_BOOKING_DETAILS ENDP

;================================================================
; PRINT_BUS_NAME
; Prints destination name only.
;================================================================
PRINT_BUS_NAME PROC
    PUSH AX
    PUSH DX
    MOV AL, SELECTED_BUS
    CMP AL, 1
    JE PBN_A
    CMP AL, 2
    JE PBN_H
    CMP AL, 3
    JE PBN_B
    JMP PBN_D
PBN_A:
    LEA DX, DEST1_NAME
    JMP PBN_PRINT
PBN_H:
    LEA DX, DEST2_NAME
    JMP PBN_PRINT
PBN_B:
    LEA DX, DEST3_NAME
    JMP PBN_PRINT
PBN_D:
    LEA DX, DEST4_NAME
PBN_PRINT:
    MOV AH, 09H
    INT 21H
    POP DX
    POP AX
    RET
PRINT_BUS_NAME ENDP

;================================================================
; PRINT_DEST_NAME
;================================================================
PRINT_DEST_NAME PROC
    PUSH AX
    PUSH DX
    MOV AL, SELECTED_BUS
    CMP AL, 1
    JE PD_A
    CMP AL, 2
    JE PD_H
    CMP AL, 3
    JE PD_B
    JMP PD_D
PD_A:
    LEA DX, DEST1_NAME
    JMP PD_PRINT
PD_H:
    LEA DX, DEST2_NAME
    JMP PD_PRINT
PD_B:
    LEA DX, DEST3_NAME
    JMP PD_PRINT
PD_D:
    LEA DX, DEST4_NAME
PD_PRINT:
    MOV AH, 09H
    INT 21H
    POP DX
    POP AX
    RET
PRINT_DEST_NAME ENDP

;================================================================
; PRINT_BOOKING_ID
; Example: ADAMA-1 / HAWASSA-3 / BISHOFTU-5 / BAHIRDAR-20
; SI = seat array index.
;================================================================
PRINT_BOOKING_ID PROC
    PUSH AX
    PUSH DX

    MOV AL, SELECTED_BUS
    CMP AL, 1
    JE PBI_A
    CMP AL, 2
    JE PBI_H
    CMP AL, 3
    JE PBI_B
    JMP PBI_D
PBI_A:
    LEA DX, ID1_NAME
    JMP PBI_PRINT
PBI_H:
    LEA DX, ID2_NAME
    JMP PBI_PRINT
PBI_B:
    LEA DX, ID3_NAME
    JMP PBI_PRINT
PBI_D:
    LEA DX, ID4_NAME
PBI_PRINT:
    MOV AH, 09H
    INT 21H
    MOV AX, SI
    INC AX
    CALL PRINT_NUMBER

    POP DX
    POP AX
    RET
PRINT_BOOKING_ID ENDP

;================================================================
; READ_NUMBER
; Reads decimal digits until Enter. Returns number in AX.
;================================================================
READ_NUMBER PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, 0
RN_LOOP:
    MOV AH, 01H
    INT 21H
    CMP AL, 13
    JE RN_DONE
    CMP AL, '0'
    JL RN_LOOP
    CMP AL, '9'
    JG RN_LOOP

    SUB AL, '0'
    MOV AH, 0
    PUSH AX
    MOV AX, BX
    MOV CX, 10
    MUL CX
    MOV BX, AX
    POP AX
    ADD BX, AX
    JMP RN_LOOP
RN_DONE:
    MOV AX, BX
    CALL NEW_LINE
    POP DX
    POP CX
    POP BX
    RET
READ_NUMBER ENDP

;================================================================
; PRINT_NUMBER
; Prints unsigned AX in decimal.
;================================================================
PRINT_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP AX, 0
    JNE PN_START
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    JMP PN_DONE
PN_START:
    MOV CX, 0
    MOV BX, 10
PN_DIV:
    MOV DX, 0
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE PN_DIV
PN_PRINT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PN_PRINT
PN_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUMBER ENDP

;================================================================
; NEW_LINE
;================================================================
NEW_LINE PROC
    PUSH AX
    PUSH DX
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    POP DX
    POP AX
    RET
NEW_LINE ENDP

END MAIN

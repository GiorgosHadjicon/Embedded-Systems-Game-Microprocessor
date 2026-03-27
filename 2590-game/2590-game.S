# LINK TO TEAM VIDEO
# https://

  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  
  .global Main
  .global SysTick_Handler
  .global EXTI0_IRQHandler

  @ Definitions are in definitions.s to keep this file "clean"
  #include "definitions.S"

  .equ    BLINK_PERIOD, 4000

  .section .text
  .type Main, %function
Main:
  PUSH  {R4-R6,LR}


  @
  @ Prepare GPIO Port E Pin 9 for output (LED LD3)
  @ We'll blink LED LD3 (the orange LED)
  @

  @ Enable GPIO port E by enabling its clock
  LDR     R4, =RCC_AHBENR
  LDR     R5, [R4]
  ORR     R5, R5, #(0b1 << (RCC_AHBENR_GPIOEEN_BIT))
  STR     R5, [R4]

  @ Configure LD3 for output
  @   by setting bits 19:18 of GPIOE_MODER to 01 (GPIO Port E Mode Register)
  @   (by BIClearing then ORRing)
  LDR     R4, =GPIOE_MODER
  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD4_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD4_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD6_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD6_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD8_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD8_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD10_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD10_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD9_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD9_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD7_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD7_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD3_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD3_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD5_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD5_PIN*2))    @ write 01 to bits 
  STR     R5, [R4]                    @ Write 

  LDR     R4, =GPIOE_ODR            @   Invert LD4
  LDR     R5, [R4]                  @
  ORR     R5, #(0b1<<(LD4_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  ORR     R5, #(0b1<<(LD6_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  ORR     R5, #(0b1<<(LD10_PIN))    @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  ORR     R5, #(0b1<<(LD9_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  ORR     R5, #(0b1<<(LD8_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  ORR     R5, #(0b1<<(LD7_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  STR     R5, [R4]                  @ 

  @ Initialise the first countdown

  LDR     R4, =blink_countdown
  LDR     R5, =BLINK_PERIOD
  STR     R5, [R4]  

  @
  @ Initialise the win_or_lose variable to 0 (not used in this part of the code, but will be used in the next part)
  @ 0 : game is ongoing
  @ 1 : player wins
  @ 2 : player loses

  LDR     R4, =win_or_lose
  MOV     R5, #0
  STR     R5, [R4]


  @ Configure SysTick Timer to generate an interrupt every 1ms

  LDR     R4, =SCB_ICSR               @ Clear any pre-existing interrupts
  LDR     R5, =SCB_ICSR_PENDSTCLR     @
  STR     R5, [R4]                    @

  LDR     R4, =SYSTICK_CSR            @ Stop SysTick timer
  LDR     R5, =0                      @   by writing 0 to CSR
  STR     R5, [R4]                    @   CSR is the Control and Status Register
  
  LDR     R4, =SYSTICK_LOAD           @ Set SysTick LOAD for 1ms delay
  LDR     R5, =7999                   @ Assuming 8MHz clock
  STR     R5, [R4]                    @ 

  LDR     R4, =SYSTICK_VAL            @   Reset SysTick internal counter to 0
  LDR     R5, =0x1                    @     by writing any value
  STR     R5, [R4]


  @ Configure USER pushbutton (GPIO Port A Pin 0 on STM32F3 Discovery
  @   kit) to use the EXTI0 external interrupt signal
  @ Determined by bits 3..0 of the External Interrrupt Control
  @   Register (EXTIICR)
  LDR     R4, =SYSCFG_EXTIICR1
  LDR     R5, [R4]
  BIC     R5, R5, #0b1111
  STR     R5, [R4]

  @ Enable (unmask) interrupts on external interrupt Line0
  LDR     R4, =EXTI_IMR
  LDR     R5, [R4]
  ORR     R5, R5, #1
  STR     R5, [R4]

  @ Set falling edge detection on Line0
  LDR     R4, =EXTI_FTSR
  LDR     R5, [R4]
  ORR     R5, R5, #1
  STR     R5, [R4]

  @ Enable NVIC interrupt #6 (external interrupt Line0)
  LDR     R4, =NVIC_ISER
  MOV     R5, #(1<<6)
  STR     R5, [R4]

  @ Nothing else to do in Main
  @ Idle loop forever (welcome to interrupts!!)
Idle_Loop:
  B     Idle_Loop
  
End_Main:
  POP   {R4-R6,PC}



@
@ SysTick interrupt handler (blink LED LD3)
@
  .type  SysTick_Handler, %function
SysTick_Handler:

  PUSH  {R4, R5, R6, LR}


@  LD4
  LDR   R4, =blink_countdown        @ if (countdown >= 1000) {
  LDR   R5, [R4]                    @
  CMP   R5, #1000                 @
  BLE   .LcloseLD4                  @
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  ORR   R5, #(0b1<<(LD4_PIN))       @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  STR     R5, [R4]                  @ 
  B     .LendLD4                     
.LcloseLD4:                         @  } else {
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  BIC    R5, #(0b1<<(LD4_PIN))      @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  STR    R5, [R4]                   @ 

.LendLD4:                           @ }

@ LD6
  LDR   R4, =blink_countdown        @ if (countdown != 2000) {
  LDR   R5, [R4]                    @
  LDR   R6, =1500                   @
  CMP   R5, R6                      @
  BGT   .LopenLD6                   @
  LDR   R6, =500                   @
  CMP   R5, R6                      @
  BGT   .LcloseLD6                  @
.LopenLD6:                          @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD6_PIN);
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  ORR   R5, #(0b1<<(LD6_PIN))       @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD6_PIN);
  STR     R5, [R4]                  @ 
  B     .LendLD6                     
.LcloseLD6:                         @  } else {
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  BIC    R5, #(0b1<<(LD6_PIN))      @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD6_PIN);
  STR    R5, [R4]                   @ 

.LendLD6:                           @ }

@ LD8
  LDR   R4, =blink_countdown        @ if (countdown != 2000) {
  LDR   R5, [R4]                    @
  LDR   R6, =2000                   @
  CMP   R5, R6                      @
  BGT   .LopenLD8                   @
  LDR   R6, =1000                   @
  CMP   R5, R6                      @
  BGT   .LcloseLD8                  @
.LopenLD8:                          @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD8_PIN);
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  ORR   R5, #(0b1<<(LD8_PIN))       @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD8_PIN);
  STR     R5, [R4]                  @ 
  B     .LendLD8                     
.LcloseLD8:                         @  } else {
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  BIC    R5, #(0b1<<(LD8_PIN))      @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD8_PIN);
  STR    R5, [R4]                   @ 

.LendLD8:                           @ }

@ LD10
  LDR   R4, =blink_countdown        @ if (countdown != 2000) {
  LDR   R5, [R4]                    @
  LDR   R6, =2500                   @
  CMP   R5, R6                      @
  BGT   .LopenLD10                  @
  LDR   R6, =1500                   @
  CMP   R5, R6                      @
  BGT   .LcloseLD10                 @
.LopenLD10:                         @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD10_PIN);
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  ORR   R5, #(0b1<<(LD10_PIN))      @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD10_PIN);
  STR     R5, [R4]                  @ 
  B     .LendLD10                     
.LcloseLD10:                        @  } else {
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  BIC    R5, #(0b1<<(LD10_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD10_PIN);
  STR    R5, [R4]                   @ 

.LendLD10:                          @ }

@ LD9
  LDR   R4, =blink_countdown        @ if (countdown != 2000) {
  LDR   R5, [R4]                    @
  LDR   R6, =3000                   @
  CMP   R5, R6                      @
  BGT   .LopenLD9                   @
  LDR   R6, =2000                   @
  CMP   R5, R6                      @
  BGT   .LcloseLD9                  @
.LopenLD9:                          @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD9_PIN);
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  ORR   R5, #(0b1<<(LD9_PIN))       @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD9_PIN);
  STR     R5, [R4]                  @ 
  B     .LendLD9                     
.LcloseLD9:                         @  } else {
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  BIC    R5, #(0b1<<(LD9_PIN))      @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD9_PIN);
  STR    R5, [R4]                   @ 

.LendLD9:                           @ }

@ LD7
  LDR   R4, =blink_countdown        @ if (countdown != 2000) {
  LDR   R5, [R4]                    @
  LDR   R6, =3500                   @
  CMP   R5, R6                      @
  BGT   .LopenLD7                   @
  LDR   R6, =2500                   @
  CMP   R5, R6                      @
  BGT   .LcloseLD7                  @
.LopenLD7:                          @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD7_PIN);
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  ORR   R5, #(0b1<<(LD7_PIN))       @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD7_PIN);
  STR     R5, [R4]                  @ 
  B     .LendLD7                     
.LcloseLD7:                         @  } else {
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  BIC    R5, #(0b1<<(LD7_PIN))      @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD7_PIN);
  STR    R5, [R4]                   @ 

.LendLD7:                           @ }

@ LD5
  LDR   R4, =blink_countdown        @ if (countdown != 2000) {
  LDR   R5, [R4]                    @
  LDR   R6, =4000                   @
  CMP   R5, R6                      @
  BGT   .LopenLD5                   @
  LDR   R6, =3000                   @
  CMP   R5, R6                      @
  BGT   .LcloseLD5                  @
.LopenLD5:                          @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD5_PIN);
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  ORR   R5, #(0b1<<(LD5_PIN))       @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD5_PIN);
  STR     R5, [R4]                  @ 
  B     .LendLD5                     
.LcloseLD5:                         @  } else {
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  BIC    R5, #(0b1<<(LD5_PIN))      @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD5_PIN);
  STR    R5, [R4]                   @ 

.LendLD5:                           @ }

@ LD3
  LDR   R4, =blink_countdown        @ if (countdown != 2000) {
  LDR   R5, [R4]                    @
  LDR   R6, =3500                   @
  CMP   R5, R6                      @
  BGT   .LcloseLD3                  @
  LDR   R6, =500                   @
  CMP   R5, R6                      @
  BLT   .LcloseLD3                  @
.LopenLD3:                          @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD3_PIN);
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  ORR   R5, #(0b1<<(LD3_PIN))       @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 
  B     .LendLD3                     
.LcloseLD3:                         @  } else {
  LDR     R4, =GPIOE_ODR            @   
  LDR     R5, [R4]                  @
  BIC    R5, #(0b1<<(LD3_PIN))      @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD3_PIN);
  STR    R5, [R4]                   @ 

.LendLD3:                           @ }


  LDR   R4, =blink_countdown        @ 
  LDR   R5, [R4]                    @
  SUB   R5, R5, #1                  @   countdown = countdown - 1;
  STR   R5, [R4]                    @


  LDR   R4, =blink_countdown        @ if (countdown != 0) {
  LDR   R5, [R4]                    @
  CMP   R5, #0                      @
  BEQ   .LresetCountdown            

  B     .LendIfDelay                @ }

.LresetCountdown:                   @ else {
  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @
  STR     R5, [R4]                  @

.LendIfDelay:                       @ }

  LDR     R4, =SCB_ICSR             @ Clear (acknowledge) the interrupt
  LDR     R5, =SCB_ICSR_PENDSTCLR   @
  STR     R5, [R4]                  @

  @ Return from interrupt handler
  POP  {R4, R5, R6, PC}



@
@ External interrupt line 0 interrupt handler
@   (count button presses)
@
  .type  EXTI0_IRQHandler, %function
EXTI0_IRQHandler:

  PUSH  {R4,R5,LR}

  LDR     R4, =SYSTICK_CSR            @   Start SysTick timer by setting CSR to 0x7
  LDR     R5, =0x7                    @     set CLKSOURCE (bit 2) to system clock (1)
  STR     R5, [R4]                    @     set TICKINT (bit 1) to 1 to enable interrupts
                                      @     set ENABLE (bit 0) to 1

  LDR   R4, =win_or_lose            @ if (win_or_lose == 0) {
  LDR   R5, [R4]                    @
  CMP   R5, #0                      @
  BNE   .LcheckIfWin                @

  BL   checkIfWin                     @   checkIfWin() to see if player has won

  B   .LendEventHandle                     @   (if player has won, checkIfWin will set win_or_lose to 1, otherwise it will leave it as 0)

.LcheckIfWin:                        @ } else {
  LDR     R4, =win_or_lose
  MOV     R5, #0
  STR     R5, [R4]                    @ win_or_lose = 0

.LendEventHandle:                @ }

  LDR   R4, =EXTI_PR                @ Clear (acknowledge) the interrupt
  MOV   R5, #(1<<0)                 @
  STR   R5, [R4]                    @

  @ Return from interrupt handler
  POP  {R4,R5,PC}






  @ SUBROUTINES
  @ checkIfWin() - checks if the player has won the game (all LEDs are off)
  @   Input: R0 = win_or_lose (should be 1 when this function is called)
  @   Output: R0 = 1 if player wins, 0

checkIfWin:
  PUSH  {R4, R5, R6, LR}

  LDR   R4, =blink_countdown        @ if (countdown != 2000) {
  LDR   R5, [R4]                    @
  LDR   R6, =2000                   @
  CMP   R5, R6                      @
  BGT   .LcheckIfWinNotLost         @
  LDR   R6, =1500                   @
  CMP   R5, R6                      @
  BLT   .LcheckIfWinNotLost         @

@ Has Lost
  LDR     R4, =SYSTICK_CSR            @ Stop SysTick timer
  LDR     R5, =0                      @   by writing 0 to CSR
  STR     R5, [R4]                    @   CSR is the Control and Status Register

  LDR     R4, =SYSTICK_VAL            @   Reset SysTick internal counter to 0
  LDR     R5, =0x1                    @     by writing any value
  STR     R5, [R4]

    @ Initialise the first countdown

  LDR     R4, =blink_countdown
  LDR     R5, =BLINK_PERIOD
  STR     R5, [R4]  

  

  LDR    R4, =win_or_lose
  LDR     R5, =2
  STR     R5, [R4]                    @ win_or_lose = 1

  LDR     R4, =GPIOE_ODR 
  LDR     R5, [R4]                    @ Read ...

  ORR     R5, #(0b1<<(LD3_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD3_PIN);
  ORR     R5, #(0b1<<(LD10_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD10_PIN);

  BIC     R5, #(0b1<<(LD4_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  BIC     R5, #(0b1<<(LD5_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<L5_PIN);
  BIC     R5, #(0b1<<(LD6_PIN))    @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD6_PIN);
  BIC     R5, #(0b1<<(LD9_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD9_PIN);
  BIC     R5, #(0b1<<(LD8_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD8_PIN);
  BIC     R5, #(0b1<<(LD7_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD7_PIN);

  STR     R5, [R4]                    @ Write 

  B      .LcheckIfWinEnd


.LcheckIfWinNotLost:
  @ LD3
  LDR   R4, =blink_countdown        @ if (countdown != 2000) {
  LDR   R5, [R4]                    @
  LDR   R6, =3500                   @
  CMP   R5, R6                      @
  BGT   .LcheckIfWinEnd                  @
  LDR   R6, =500                   @
  CMP   R5, R6                      @
  BLT   .LcheckIfWinEnd                 @
.LisOpenLD3:                          @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD3_PIN);

  LDR     R4, =SYSTICK_CSR            @ Stop SysTick timer
  LDR     R5, =0                      @   by writing 0 to CSR
  STR     R5, [R4]                    @   CSR is the Control and Status Register

  LDR     R4, =SYSTICK_VAL            @   Reset SysTick internal counter to 0
  LDR     R5, =0x1                    @     by writing any value
  STR     R5, [R4]

    @ Initialise the first countdown

  LDR     R4, =blink_countdown
  LDR     R5, =BLINK_PERIOD
  STR     R5, [R4]  

  LDR    R4, =win_or_lose
  LDR     R5, =1
  STR     R5, [R4]                    @ win_or_lose = 1

  LDR     R4, =GPIOE_ODR 
  LDR     R5, [R4]                    @ Read ...

  ORR     R5, #(0b1<<(LD7_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD7_PIN);
  ORR     R5, #(0b1<<(LD6_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD6_PIN);

  BIC     R5, #(0b1<<(LD4_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  BIC     R5, #(0b1<<(LD5_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD5_PIN);
  BIC     R5, #(0b1<<(LD10_PIN))    @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD10_PIN);
  BIC     R5, #(0b1<<(LD9_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD9_PIN);
  BIC     R5, #(0b1<<(LD8_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD8_PIN);
  BIC     R5, #(0b1<<(LD3_PIN))     @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD3_PIN);

  STR     R5, [R4]                    @ Write 


                    
.LcheckIfWinEnd:                @ }

  POP   {R4, R5, R6, PC}



  .section .data

blink_countdown:
  .space  4

win_or_lose:
  .space  4


  .end
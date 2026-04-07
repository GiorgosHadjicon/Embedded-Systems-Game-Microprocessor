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

  @ Configure All LEDs for output
  @   by setting their respective bits of GPIOE_MODER to 01 (GPIO Port E Mode Register)
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
  BIC     R5, #(0b11<<(LD10_PIN*2))   @ Modify ...
  ORR     R5, #(0b01<<(LD10_PIN*2))   @ write 01 to bits 
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

  LDR     R4, =GPIOE_ODR              @   Invert LD4
  LDR     R5, [R4]                    @
  ORR     R5, #(0b1<<(LD4_PIN))       @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  ORR     R5, #(0b1<<(LD6_PIN))       @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  ORR     R5, #(0b1<<(LD10_PIN))      @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  ORR     R5, #(0b1<<(LD9_PIN))       @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  ORR     R5, #(0b1<<(LD8_PIN))       @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  ORR     R5, #(0b1<<(LD7_PIN))       @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD4_PIN);
  STR     R5, [R4]                    @ 

  @ Initialise the first countdown

  LDR     R4, =blink_countdown
  LDR     R5, =BLINK_PERIOD
  STR     R5, [R4]  

  
  @ Initialise the level selected to 1 (easy)

  LDR     R4, =1
  LDR     R5, =level_selected
  STR     R4, [R5]  

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
  LDR     R4, =blink_countdown        @ if (countdown >= 1000) {
  LDR     R5, [R4]                    @
  CMP     R5, #1000                 @
  BLE     .LcloseLD4                  @
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  ORR     R5, #(0b1<<(LD4_PIN))       @   Modify ... (set bit LD4_PIN to 1)
  STR     R5, [R4]                    @   Write 
  B     .LendLD4                     
.LcloseLD4:                           @  } else {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  BIC     R5, #(0b1<<(LD4_PIN))       @   Modify ... (set bit LD4_PIN to 0)
  STR     R5, [R4]                    @   Write 

.LendLD4:                             @ }

@ LD6
  LDR     R4, =blink_countdown        @ if (countdown > 1500 || countdown <= 500) 
  LDR     R5, [R4]                    @
  LDR     R6, =1500                   @
  CMP     R5, R6                      @
  BGT     .LopenLD6                   @
  LDR     R6, =500                    @
  CMP     R5, R6                      @
  BGT     .LcloseLD6                  @
.LopenLD6:                            @   {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  ORR     R5, #(0b1<<(LD6_PIN))       @   Modify ... (set bit LD6_PIN to 1)
  STR     R5, [R4]                    @   Write 
  B       .LendLD6                     
.LcloseLD6:                           @  } else {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  BIC     R5, #(0b1<<(LD6_PIN))       @   Modify ... (set bit LD6_PIN to 0)
  STR     R5, [R4]                    @   Write 

.LendLD6:                             @ }

@ LD8
  LDR     R4, =blink_countdown        @ if (countdown > 2000 || countdown <= 1000) 
  LDR     R5, [R4]                    @
  LDR     R6, =2000                   @
  CMP     R5, R6                      @
  BGT     .LopenLD8                   @
  LDR     R6, =1000                   @
  CMP     R5, R6                      @
  BGT     .LcloseLD8                  @
.LopenLD8:                            @   {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  ORR     R5, #(0b1<<(LD8_PIN))       @   Modify ... (set bit LD8_PIN to 1)
  STR     R5, [R4]                    @   Write 
  B     .LendLD8                     
.LcloseLD8:                           @  } else {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  BIC     R5, #(0b1<<(LD8_PIN))       @   Modify ... (set bit LD8_PIN to 0)
  STR     R5, [R4]                    @   Write 

.LendLD8:                             @ }

@ LD10
  LDR     R4, =blink_countdown        @ if (countdown > 2500 || countdown <= 1500) 
  LDR     R5, [R4]                    @
  LDR     R6, =2500                   @
  CMP     R5, R6                      @
  BGT     .LopenLD10                  @
  LDR     R6, =1500                   @
  CMP     R5, R6                      @
  BGT     .LcloseLD10                 @
.LopenLD10:                           @   {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  ORR     R5, #(0b1<<(LD10_PIN))      @   Modify ... (set bit LD10_PIN to 1)
  STR     R5, [R4]                    @   Write 
  B       .LendLD10                    
.LcloseLD10:                          @  } else {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  BIC     R5, #(0b1<<(LD10_PIN))      @   Modify ... (set bit LD10_PIN to 0)
  STR     R5, [R4]                    @   Write 

.LendLD10:                            @ }

@ LD9
  LDR     R4, =blink_countdown        @ if (countdown > 3000 || countdown <= 2000) 
  LDR     R5, [R4]                    @
  LDR     R6, =3000                   @
  CMP     R5, R6                      @
  BGT     .LopenLD9                   @
  LDR     R6, =2000                   @
  CMP     R5, R6                      @
  BGT     .LcloseLD9                  @
.LopenLD9:                            @   {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  ORR     R5, #(0b1<<(LD9_PIN))       @   Modify ... (set bit LD9_PIN to 1)
  STR     R5, [R4]                    @   Write 
  B       .LendLD9                     
.LcloseLD9:                           @  } else {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  BIC     R5, #(0b1<<(LD9_PIN))       @   Modify ... (set bit LD9_PIN to 0)
  STR     R5, [R4]                    @   Write 

.LendLD9:                             @ }

@ LD7
  LDR     R4, =blink_countdown        @ if (countdown > 3500 || countdown <= 2500) 
  LDR     R5, [R4]                    @
  LDR     R6, =3500                   @
  CMP     R5, R6                      @
  BGT     .LopenLD7                   @
  LDR     R6, =2500                   @
  CMP     R5, R6                      @
  BGT     .LcloseLD7                  @
.LopenLD7:                            @   {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  ORR     R5, #(0b1<<(LD7_PIN))       @   Modify ... (set bit LD7_PIN to 1)
  STR     R5, [R4]                    @   Write 
  B       .LendLD7                     
.LcloseLD7:                           @  } else {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  BIC     R5, #(0b1<<(LD7_PIN))       @   Modify ... (set bit LD7_PIN to 0)
  STR     R5, [R4]                    @   Write 

.LendLD7:                             @ }

@ LD5
  LDR     R4, =blink_countdown        @ if (countdown > 4000 || countdown <= 3000) 
  LDR     R5, [R4]                    @
  LDR     R6, =4000                   @
  CMP     R5, R6                      @
  BGT     .LopenLD5                   @
  LDR     R6, =3000                   @
  CMP     R5, R6                      @
  BGT     .LcloseLD5                  @
.LopenLD5:                            @   {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  ORR     R5, #(0b1<<(LD5_PIN))       @   Modify ... (set bit LD5_PIN to 1)
  STR     R5, [R4]                    @   Write 
  B       .LendLD5                     
.LcloseLD5:                           @  } else {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  BIC     R5, #(0b1<<(LD5_PIN))       @   Modify ... (set bit LD5_PIN to 0)
  STR     R5, [R4]                    @   Write 

.LendLD5:                             @ }

@ LD3
  LDR     R4, =blink_countdown        @ if (countdown <= 3500 && countdown >= 500) 
  LDR     R5, [R4]                    @
  LDR     R6, =3500                   @
  CMP     R5, R6                      @
  BGT     .LcloseLD3                  @
  LDR     R6, =500                    @
  CMP     R5, R6                      @
  BLT     .LcloseLD3                  @
.LopenLD3:                            @   {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  ORR     R5, #(0b1<<(LD3_PIN))       @   Modify ... (set bit LD3_PIN to 1)
  STR     R5, [R4]                    @   Write 
  B       .LendLD3                     
.LcloseLD3:                           @  } else {
  LDR     R4, =GPIOE_ODR              @   
  LDR     R5, [R4]                    @   Read ...
  BIC     R5, #(0b1<<(LD3_PIN))       @   Modify ... (set bit LD3_PIN to 0)
  STR     R5, [R4]                    @   Write 

.LendLD3:                             @ }


  LDR     R4, =blink_countdown        @ 
  LDR     R5, [R4]                    @   Read ...
  SUB     R5, R5, #1                  @   Modify ... (countdown = countdown - 1)
  STR     R5, [R4]                    @   Write 


  LDR     R4, =blink_countdown        @ if (countdown != 0) {
  LDR     R5, [R4]                    @
  CMP     R5, #0                      @
  BEQ     .LresetCountdown            

  B       .LendIfDelay                @ }

.LresetCountdown:                     @ else {
  LDR     R4, =blink_countdown        @   Read ...
  LDR     R5, =BLINK_PERIOD           @   Modify ... (countdown = BLINK_PERIOD) [Reset countdown]
  STR     R5, [R4]                    @   Write 

.LendIfDelay:                         @ }

  LDR     R4, =SCB_ICSR               @ Clear (acknowledge) the interrupt
  LDR     R5, =SCB_ICSR_PENDSTCLR     @
  STR     R5, [R4]                    @

  @ Return from interrupt handler
  POP  {R4, R5, R6, PC}



@
@ External interrupt line 0 interrupt handler
@   (count button presses)
@
  .type  EXTI0_IRQHandler, %function
EXTI0_IRQHandler:

  PUSH  {R4,R5,LR}

  LDR     R4, =win_or_lose            @ if (win_or_lose == 2) {
  LDR     R5, [R4]                    @ 
  CMP     R5, #2                      @
  BEQ     .LendEventHandle            @   branch to end of event handler (do nothing if player has lost and button is pressed again)
  LDR     R4, =level_selected         @ if (level_selected == 4) {
  LDR     R5, [R4]                    @
  CMP     R5, #4                      @
  BEQ     .LendEventHandle            @   branch to end of event handler (do nothing if player has lost and button is pressed again) }

  LDR     R4, =SYSTICK_CSR            @   Start SysTick timer by setting CSR to 0x7
  LDR     R5, =0x7                    @     set CLKSOURCE (bit 2) to system clock (1)
  STR     R5, [R4]                    @     set TICKINT (bit 1) to 1 to enable interrupts
                                      @     set ENABLE (bit 0) to 1

  LDR     R4, =win_or_lose            @ if (win_or_lose == 0) {
  LDR     R5, [R4]                    @
  CMP     R5, #0                      @
  BNE     .LcheckIfWin                @

  BL      checkIfWin                  @   checkIfWin() [to see if player has won]

  B       .LendEventHandle            @   (if player has won, checkIfWin will set win_or_lose to 1, otherwise it will leave it as 0)

.LcheckIfWin:                         @ } else {
  LDR     R4, =win_or_lose            @ if (win_or_lose != 2) {
  LDR     R5, [R4]                    @      
  CMP     R5, #2                      @            
  BEQ     .LendEventHandle            @   
  MOV     R5, #0                      @   Modify ... (win_or_lose = 0) [Reset win_or_lose to 0 to indicate game is ongoing again]
  STR     R5, [R4]                    @   Write 

.LendEventHandle:                     @ }

  LDR     R4, =EXTI_PR                @ Clear (acknowledge) the interrupt
  MOV     R5, #(1<<0)                 @
  STR     R5, [R4]                    @

  @ Return from interrupt handler
  POP  {R4,R5,PC}






  @ SUBROUTINES
  @ checkIfWin() - checks if the player has won the game 
  @   Input: variable win_or_lose 
  @   Output:  variable win_or_lose is 1 if player has won, 2 if player has lost

checkIfWin:
  PUSH  {R4, R5, R6, LR}

  LDR     R4, = level_selected
  LDR     R5, [R4]                    @ if (level_selected == 1) {
  CMP     R5, #1                      @
  BEQ     .LcheckIfWinIsLevel1        @   branch to level 1  
  CMP     R5, #2                      @ } else if (level_selected == 2) { 
  BEQ     .LcheckIfWinIsLevel2        @   branch to level 2
                                      @ }

  @ Level 3
  @ Bullet in LD4
  LDR     R4, =blink_countdown        @ if (countdown <= 3500 && countdown >= 3000) {
  LDR     R5, [R4]                    @   
  LDR     R6, =3500                   @
  CMP     R5, R6                      @
  BGT     .LcheckIfWinIsLevel2        @
  LDR     R6, =3000                   @
  CMP     R5, R6                      @
  BLT     .LcheckIfWinIsLevel2        @

  B       .LcheckIfWinDead            @   branch to player has died
                                      @ }   

.LcheckIfWinIsLevel2:
  @ Bullet in LD7
  LDR     R4, =blink_countdown        @ if (countdown <= 1000 && countdown >= 500) {
  LDR     R5, [R4]                    @   
  LDR     R6, =1000                   @
  CMP     R5, R6                      @
  BGT     .LcheckIfWinIsLevel1        @         
  LDR     R6, =500                    @
  CMP     R5, R6                      @
  BLT     .LcheckIfWinIsLevel1        @    

  B       .LcheckIfWinDead            @   branch to player has died
                                      @ }   
.LcheckIfWinIsLevel1:
  @ Bullet in LD10
  LDR     R4, =blink_countdown        @ if (countdown <= 2000 && countdown >= 1500) {
  LDR     R5, [R4]                    @
  LDR     R6, =2000                   @
  CMP     R5, R6                      @
  BGT     .LcheckIfWinNotLost         @
  LDR     R6, =1500                   @
  CMP     R5, R6                      @
  BLT     .LcheckIfWinNotLost         @

.LcheckIfWinDead:
@ Has Lost
  LDR     R4, =SYSTICK_CSR            @ Stop SysTick timer
  LDR     R5, =0                      @   by writing 0 to CSR
  STR     R5, [R4]                    @   CSR is the Control and Status Register

  LDR     R4, =SYSTICK_VAL            @ Reset SysTick internal counter to 0
  LDR     R5, =0x1                    @   by writing any value
  STR     R5, [R4]

  @ Reset the countdown

  LDR     R4, =blink_countdown
  LDR     R5, =BLINK_PERIOD
  STR     R5, [R4]  

  

  LDR     R4, =win_or_lose
  LDR     R5, =2
  STR     R5, [R4]                    @ win_or_lose = 2

  LDR     R4, =GPIOE_ODR 
  LDR     R5, [R4]                    @ Read ...

  ORR     R5, #(0b1<<(LD3_PIN))       @   Modify ... (set bit LD3_PIN to 1) [to indicate player has lost Opens Red LED]
  ORR     R5, #(0b1<<(LD10_PIN))      @   Modify ... (set bit LD10_PIN to 1)

  BIC     R5, #(0b1<<(LD4_PIN))       @   Modify ... (set bit LD4_PIN to 0)
  BIC     R5, #(0b1<<(LD5_PIN))       @   Modify ... (set bit LD5_PIN to 0)
  BIC     R5, #(0b1<<(LD6_PIN))       @   Modify ... (set bit LD6_PIN to 0)
  BIC     R5, #(0b1<<(LD9_PIN))       @   Modify ... (set bit LD9_PIN to 0)
  BIC     R5, #(0b1<<(LD8_PIN))       @   Modify ... (set bit LD8_PIN to 0)
  BIC     R5, #(0b1<<(LD7_PIN))       @   Modify ... (set bit LD7_PIN to 0)

  STR     R5, [R4]                    @ Write 

  B      .LcheckIfWinEnd              @ }


.LcheckIfWinNotLost:

  @ Check if blank
  LDR     R4, =blink_countdown        @ if (countdown <= 3500 && countdown >= 500) {
  LDR     R5, [R4]                    @
  LDR     R6, =3500                   @
  CMP     R5, R6                      @
  BGT     .LcheckIfWinEnd             @
  LDR     R6, =500                    @
  CMP     R5, R6                      @
  BLT     .LcheckIfWinEnd             @
.LisOpenLD3:                          @   GPIOE_ODR = GPIOE_ODR ^ (1<<LD3_PIN);

  LDR     R4, =SYSTICK_CSR            @   Stop SysTick timer
  LDR     R5, =0                      @     by writing 0 to CSR
  STR     R5, [R4]                    @     CSR is the Control and Status Register

  LDR     R4, =SYSTICK_VAL            @   Reset SysTick internal counter to 0
  LDR     R5, =0x1                    @     by writing any value
  STR     R5, [R4]



  @ Reset the countdown

  LDR     R4, =blink_countdown
  LDR     R5, =BLINK_PERIOD
  STR     R5, [R4]  

  LDR     R4, =win_or_lose            @  Read
  LDR     R5, =1                      @  Modify ... (win_or_lose = 1) [to indicate player has won]
  STR     R5, [R4]                    @  Write

  LDR     R4, =level_selected
  LDR     R5, [R4]                    @  Read  
  ADD     R5, R5, #1                  @  Modify ... (level_selected = level_selected + 1) [to move on to the next level]
  STR     R5, [R4]                    @  Write 

  LDR     R4, =GPIOE_ODR 
  LDR     R5, [R4]                    @ Read ...

  ORR     R5, #(0b1<<(LD7_PIN))       @   Modify ... (set bit LD7_PIN to 1) [to indicate player has won - Opens Green LED]
  ORR     R5, #(0b1<<(LD6_PIN))       @   Modify ... (set bit LD6_PIN to 1) 

  BIC     R5, #(0b1<<(LD4_PIN))       @   Modify ... (set bit LD4_PIN to 0)
  BIC     R5, #(0b1<<(LD5_PIN))       @   Modify ... (set bit LD5_PIN to 0)
  BIC     R5, #(0b1<<(LD10_PIN))      @   Modify ... (set bit LD10_PIN to 0)
  BIC     R5, #(0b1<<(LD9_PIN))       @   Modify ... (set bit LD9_PIN to 0)
  BIC     R5, #(0b1<<(LD8_PIN))       @   Modify ... (set bit LD8_PIN to 0)
  BIC     R5, #(0b1<<(LD3_PIN))       @   Modify ... (set bit LD3_PIN to 0)

  STR     R5, [R4]                    @ Write 

                    
.LcheckIfWinEnd:                      @ }

  POP   {R4, R5, R6, PC}



  .section .data

blink_countdown:
  .space  4

win_or_lose:
  .space  4

level_selected:
  .space  4


  .end
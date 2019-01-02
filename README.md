# 3 BLINK INTERRUPT WITH ASSEMBLY ON ARDUINO UNO

;;;; 3 BLINK INTERRUPT FIX
;
; ARDUINO UNO - ATMEGA328P - CLOCK 16MHz
;
;   NO PRESCALER F = 16 MHz     -> T = 1/16 uS   -> 1/16 uS * 255   = 16 uS (1x OVERFLOW)
; /256 PRESCALER F = 16/256 MHz -> T = 256/16 uS -> 256/16 uS * 255 = 4 mS (1x OVERFLOW)     FIX USE /256 PRESCALER
;
; FIND START TCNT0 
;  IF 1 = 0 mS and 255 = 4 mS  so.. to get 1 mS is
;    -> 255/x = 4/1
;    -> x = 255/4 
;    -> x = 63.75  (~64)
;

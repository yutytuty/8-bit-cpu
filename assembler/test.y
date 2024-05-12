jmp @_start
_start:
  mov %ar, $28255
  mov %cr, $0
loop:
  ld %cr, %ar ; load [ar] into cr
  jmp @loop

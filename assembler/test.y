jmp @_start
_start:
  ; top_ptr = [28255]
  mov %ar, $5
  mov %br, $28256 ; br=buf[0]
loop:
  ld %cr, $28255 ; cr=top_ptr
  cmp %cr, %br
  jz @loop
  ld %ar, %br
  add %br, $1
  jmp @loop

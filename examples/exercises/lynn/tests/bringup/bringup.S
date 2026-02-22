// C Runtime entry point
// Max Conine
// mconine@g.hmc.edu
// 2/18/2026

.extern add_test
.extern or_test
.extern and_test
.extern sub_test
.extern addi_test
.extern subi_test
.extern lw_test
.extern sw_test
.extern slt_test
.extern xor_test
.extern slti_test
.extern xori_test
.extern ori_test
.extern andi_test
.extern beq_test
.extern jal_test

 .section .text.init
 .globl main
 .globl return_add_test
 .globl return_or_test
 .globl return_and_test
 .globl return_sub_test
 .global return_lw_test
 .globl return_addi_test
 .global return_subi_test
 .globl return_sw_test
 .globl return_slt_test
 .globl return_xor_test
 .global return_slti_test
 .global return_xori_test
 .global return_ori_test
 .global return_andi_test
 .global return_beq_test
 .global return_jal_test
 .type main, @function

main:
 j add_test

return_add_test:
 j or_test

return_or_test:
 j and_test

return_and_test:
 j addi_test

return_addi_test:
 j subi_test

return_subi_test:
 j lw_test

return_lw_test:
 j sw_test

return_sw_test:
 j slt_test

return_slt_test:
 j xor_test

return_xor_test:
 j slti_test

return_slti_test:
 j xori_test

return_xori_test:
 j ori_test

return_ori_test:
 j andi_test

return_andi_test:
 j beq_test

return_beq_test:
 j jal_test

return_jal_test:
 j pass

// Fail ranges:
// lw: 600
// add: 300
// sub: 410
// addi: 400
// subi: 500
// or: 100
// sw: 700
// slt: 800
// slti: 810
// xor: 600 -- kinda cooked and xori is too
// ori 820
// and 200
// andi 210
// beq 1000
// jal 1100

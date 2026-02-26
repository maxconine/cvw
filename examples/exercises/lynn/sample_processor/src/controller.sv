// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

`include "parameters.svh"

module controller(
        input   logic [6:0]   Op,
        input   logic         Eq, Lt, Ltu,
        input   logic [2:0]   Funct3,
        input   logic         Funct7b5,
        output  logic         ALUResultSrc,
        output  logic         ResultSrc,
        output  logic         PCSrc,
        output  logic         RegWrite,
        output  logic         MemWrite,
        output  logic [2:0]   ALUSrc,
        output  logic [2:0]   ImmSrc,
        output  logic [1:0]   ALUControl,
        output  logic         MemEn
    `ifdef DEBUG
        , input   logic [31:0]  insn_debug
    `endif
    );

    logic Branch, TakeBranch, Jump;
    logic Sub, ALUOp;
    logic [13:0] controls;

    // Main decoder
    always_comb
        case(Op)
            // RegWrite_ImmSrc_ALUSrc_ALUOp_ALUResultSrc_MemWrite_ResultSrc_Branch_Jump_Load
            7'b0000011: controls = 15'b1_000_001_0_0_0_1_0_0_1; // lw
            7'b0100011: controls = 15'b0_001_001_0_0_1_0_0_0_1; // sw
            7'b0110011: controls = 15'b1_xxx_000_1_0_0_0_0_0_0; // R-type
            7'b0010011: controls = 15'b1_000_001_1_0_0_0_0_0_0; // I-type ALU
            7'b0000011: controls = 15'b1_000_001_0_0_0_1_0_0_1; // ALL LOADS (lb, lh, lw, lbu, lhu)
            7'b0100011: controls = 15'b0_001_001_0_0_1_0_0_0_1; // ALL STORES (sb, sh, sw)
            7'b1100011: controls = 15'b0_010_011_0_0_0_0_1_0_0; // beq
            7'b1101111: controls = 15'b1_011_011_0_1_0_0_0_1_0; // jal
            7'b0110111: controls = 15'b1_100_101_0_0_0_0_0_0_0; // lui
            7'b0010111: controls = 15'b1_100_011_0_0_0_0_0_0_0; // auipc  FIX THIS
            default: begin
                `ifdef DEBUG
                    controls = 12'bx_xx_xx_x_x_x_x_x_x_x; // non-implemented instruction
                    if ((insn_debug !== 'x)) begin
                        $display("Instruction not implemented: %h", insn_debug);
                        $finish(-1);
                    end
                `else
                    controls = 12'b0; // non-implemented instruction
                `endif
            end
        endcase

    assign {RegWrite, ImmSrc, ALUSrc, ALUOp, ALUResultSrc, MemWrite,
        ResultSrc, Branch, Jump, MemEn} = controls;

    // ALU Control Logic
    assign Sub = ALUOp & ((Funct3 == 3'b000) & Funct7b5 & Op[5] | (Funct3 == 3'b010)); // subtract or SLT
    assign ALUControl = {Sub, ALUOp};

    // PCSrc logic
    always_comb begin
        case (Funct3)
            3'b000: TakeBranch = Eq;            // BEQ
            3'b001: TakeBranch = !Eq;           // BNE
            3'b100: TakeBranch = Lt;            // BLT
            3'b101: TakeBranch = !Lt;           // BGE
            3'b110: TakeBranch = Ltu;           // BLTU
            3'b111: TakeBranch = !Ltu;          // BGEU
            default: TakeBranch = 1'b0;
        endcase
    end
    assign PCSrc = (Branch & TakeBranch) | Jump;

endmodule

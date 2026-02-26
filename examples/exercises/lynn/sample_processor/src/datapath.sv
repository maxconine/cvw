// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

module datapath(
        input   logic           clk, reset,
        input   logic [2:0]     Funct3,
        input   logic           ALUResultSrc, ResultSrc,
        input   logic [2:0]     ALUSrc,
        input   logic           RegWrite, MemWrite,
        input   logic [2:0]     ImmSrc,
        input   logic [1:0]     ALUControl,
        output  logic           Eq, Lt, Ltu,
        input   logic [31:0]    PC, PCPlus4,
        input   logic [31:0]    Instr,
        output  logic [31:0]    IEUAdr, WriteData,
        output  logic [3:0]     WriteByteEn,
        input   logic [31:0]    ReadData
    );

    logic [31:0] ImmExt;
    logic [31:0] R1, R2, SrcA, SrcB;
    logic [31:0] ALUResult, IEUResult, Result;
    logic [31:0] FormattedReadData;

    // register file logic
    regfile rf(.clk, .WE3(RegWrite), .A1(Instr[19:15]), .A2(Instr[24:20]),
        .A3(Instr[11:7]), .WD3(Result), .RD1(R1), .RD2(R2));

    extend ext(.Instr(Instr[31:7]), .ImmSrc, .ImmExt);

    // ALU logic
    cmp cmp(.R1(R1), .R2(R2), .Eq(Eq), .Lt(Lt), .Ltu(Ltu));

    // mux2 #(32) srcamux(R1, PC, ALUSrc[1], SrcA);
    mux3 #(32) srcamux(R1, PC, 32'b0, ALUSrc[2:1], SrcA); // added 3rd input for lui/auipc
    mux2 #(32) srcbmux(R2, ImmExt, ALUSrc[0], SrcB);

    alu alu(.SrcA, .SrcB, .ALUControl, .Funct3, .Funct7_5(Instr[30]), .ALUResult, .IEUAdr);

    lsu lsu_inst(
        .Adr(IEUAdr),
        .WD_in(R2),
        .MemWrite(MemWrite),
        .Funct3(Funct3),
        .RD_in(ReadData),
        .WriteByteEn(WriteByteEn),
        .WD_out(WriteData),               // Formatted store data replaces the old 'assign'
        .RD_out(FormattedReadData)        // Sign-extended load data
    );

    mux2 #(32) ieuresultmux(ALUResult, PCPlus4, ALUResultSrc, IEUResult);
    mux2 #(32) resultmux(IEUResult, FormattedReadData, ResultSrc, Result);

endmodule

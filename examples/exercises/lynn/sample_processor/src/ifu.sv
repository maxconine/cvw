// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020 kacassidy@hmc.edu 2025

module ifu(
        input   logic           clk, reset,
        input   logic [1:0]     PCSrc,
        input   logic [31:0]    IEUAdr, ImmExt,
        output  logic [31:0]    PC, PCPlus4
    );

    logic [31:0] PCNext;
    // next PC logic
    logic [31:0] entry_addr;
    logic [31:0] PCTarget;

    initial begin
        // default
        entry_addr = '0;

        // override if provided
        void'($value$plusargs("ENTRY_ADDR=%h", entry_addr));

        $display("[TB] ENTRY_ADDR = 0x%h", entry_addr);
    end

    always_ff @(posedge clk or posedge reset) begin
    if (reset)  PC <= entry_addr;
    else        PC <= PCNext;
    end

    adder pcadd4(PC, 32'd4, PCPlus4);
    // mux2 #(32) pcmux(PCPlus4, IEUAdr, PCSrc, PCNext);
    // 00: Normal execution (PC + 4)
    // 01: Branches and JAL (PC + Imm)
    // 10: JALR (ALUResult/IEUAdr)
    assign PCTarget = PC + ImmExt;

    mux3 #(32) pcmux(PCPlus4, PCTarget, (IEUAdr & 32'hFFFFFFFE), PCSrc, PCNext);
endmodule

module lsu(
    input  logic [31:0] Adr,        // From ALU (IEUAdr)
    input  logic [31:0] WD_in,      // From Register File (R2)
    input  logic        MemWrite,   // From Controller (1-bit)
    input  logic [2:0]  Funct3,     // From Instruction
    input  logic [31:0] RD_in,      // Raw data returning from DTIM memory

    output logic [3:0]  WriteByteEn, // 4-bit enable going TO DTIM
    output logic [31:0] WD_out,      // Formatted data going TO DTIM
    output logic [31:0] RD_out       // Sign-extended data going TO Result Mux
);

    logic [1:0] offset;
    assign offset = Adr[1:0]; // The bottom 2 bits dictate byte alignment

    // ==========================================
    // STORE LOGIC (Generating WriteByteEn & WD)
    // ==========================================
    // A classic hardware trick: We duplicate the byte/halfword across the
    // whole 32-bit bus, and let the WriteByteEn mask dictate what actually saves!
    always_comb begin
        if (MemWrite) begin
            case (Funct3)
                3'b000: begin // SB (Store Byte)
                    WriteByteEn = 4'b0001 << offset;
                    WD_out      = {4{WD_in[7:0]}}; // Replicate byte 4 times
                end
                3'b001: begin // SH (Store Halfword)
                    WriteByteEn = (offset[1] == 1'b0) ? 4'b0011 : 4'b1100;
                    WD_out      = {2{WD_in[15:0]}}; // Replicate halfword 2 times
                end
                3'b010: begin // SW (Store Word)
                    WriteByteEn = 4'b1111;
                    WD_out      = WD_in;
                end
                default: begin
                    WriteByteEn = 4'b0000;
                    WD_out      = 32'b0;
                end
            endcase
        end else begin
            WriteByteEn = 4'b0000; // Don't write if MemWrite is 0
            WD_out      = 32'b0;
        end
    end

    // ==========================================
    // LOAD LOGIC (The "Load Extender" Muxes)
    // ==========================================
    logic [7:0]  byte_val;
    logic [15:0] half_val;

    // 1. Extract the correct Byte
    always_comb begin
        case (offset)
            2'b00: byte_val = RD_in[7:0];
            2'b01: byte_val = RD_in[15:8];
            2'b10: byte_val = RD_in[23:16];
            2'b11: byte_val = RD_in[31:24];
        endcase
    end

    // 2. Extract the correct Halfword
    always_comb begin
        case (offset[1])
            1'b0: half_val = RD_in[15:0];
            1'b1: half_val = RD_in[31:16];
        endcase
    end

    // 3. Sign/Zero Extend based on Funct3 (Matches your 4th Image table!)
    always_comb begin
        case (Funct3)
            3'b000: RD_out = {{24{byte_val[7]}}, byte_val};   // lb  (Sign-extend Byte)
            3'b001: RD_out = {{16{half_val[15]}}, half_val};  // lh  (Sign-extend Half)
            3'b010: RD_out = RD_in;                           // lw  (Word)
            3'b100: RD_out = {24'b0, byte_val};               // lbu (Zero-extend Byte)
            3'b101: RD_out = {16'b0, half_val};               // lhu (Zero-extend Half)
            default: RD_out = 32'b0;
        endcase
    end

endmodule

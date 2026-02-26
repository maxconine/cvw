`timescale 1ns/1ps

module jalr_testbench;
  logic clk, reset;

  // Interface signals
  logic [31:0] PC, Instr, DataAdr, WriteData, ReadData;
  logic [3:0]  WriteByteEn;
  logic        MemEn, WriteEn;

  // Generate Clock
  initial clk = 0;
  always #5 clk = ~clk;

  // DUT Instantiation
  // Ensure "dut" hierarchy matches your internal names (ieu, dp, rf)
  riscvsingle dut (
    .clk(clk), .reset(reset),
    .PC(PC), .Instr(Instr),
    .IEUAdr(DataAdr), .ReadData(ReadData),
    .WriteData(WriteData), .MemEn(MemEn),
    .WriteEn(WriteEn), .WriteByteEn(WriteByteEn)
  );

  // Monitors and Checkers
  always @(negedge clk) begin
    if (!reset) begin
      // Detect the JALR instruction (Opcode 1100111)
      if (Instr[6:0] == 7'b1100111) begin
        $display("[%0t] >>> JALR DETECTED at PC: %h", $time, PC);

        // Use a non-blocking check for the NEXT clock cycle
        fork
          begin
            @(posedge clk); #1; // Wait for write-back to finish

            // CHECK 1: Did we jump to the right place?
            // Address = rs1 + imm (masked LSB to 0)
            if (PC !== (dut.ieu.dp.IEUAdr & 32'hFFFFFFFE)) begin
              $display("ERROR: Jump failed! PC is %h, expected %h", PC, (dut.ieu.dp.IEUAdr & 32'hFFFFFFFE));
            end else begin
              $display("SUCCESS: PC updated to %h", PC);
            end

            // CHECK 2: Did we save the return address?
            // ra (x1) should be old_PC + 4
            if (dut.ieu.dp.rf.rf[1] !== 32'h80001508) begin
              $display("ERROR 2302: 'ra' (x1) is %h, expected 80001508", dut.ieu.dp.rf.rf[1]);
            end else begin
              $display("SUCCESS: 'ra' (x1) correctly saved 0x80001508");
            end
          end
        join_none
      end
    end
  end

  initial begin
    reset = 1; #12; reset = 0;
    $display("Starting JALR specialized test...");

    // Safety timeout
    #2000;
    $display("Simulation timeout reach.");
    $finish;
  end
endmodule

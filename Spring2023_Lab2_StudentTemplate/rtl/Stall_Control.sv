//***********************************************************
// ECE 3058 Architecture Concurrency and Energy in Computation
//
// RISCV Processor System Verilog Behavioral Model
//
// School of Electrical & Computer Engineering
// Georgia Institute of Technology
// Atlanta, GA 30332
//
//  Module:     core_tb
//  Functionality:
//      Stall Controller for a 5 Stage RISCV Processor
//
//***********************************************************
import CORE_PKG::*;

module Stall_Control (
  input logic reset, 

  input logic [6:0] ID_instr_opcode_ip,
  input logic [4:0] ID_src1_addr_ip,
  input logic [4:0] ID_src2_addr_ip,

  //The destination register from the different stages
  input logic [4:0] EX_reg_dest_ip,  // destination register from EX pipe
  input logic [4:0] LSU_reg_dest_ip,
  input logic [4:0] WB_reg_dest_ip,
  input logic WB_write_reg_en_ip,

  // The opcode of the current instr. in ID/EX
  input [6:0] EX_instr_opcode_ip,

  output logic stall_op
);

  logic [4:0] src1;
  logic [4:0] src2;
  logic [4:0] e_rd;
  logic [4:0] m_rd;
  logic [4:0] wb_rd;

  assign src1 = ID_src1_addr_ip;
  assign src2 = ID_src2_addr_ip;
  assign e_rd = EX_reg_dest_ip;
  assign m_rd = LSU_reg_dest_ip;
  assign wb_rd = WB_reg_dest_ip;

  always_comb begin
    stall_op = 1'b0;
    case(ID_instr_opcode_ip) 

      OPCODE_OP: begin
        
        /**
        * Task 1
        * 
        * Here you will need to decide when to pull the stall control logic high. 
        * 
        * 1. Load to use stalls
        * 2. Stalls when reading and writing from Register File
        * For Register Register instructions, what registers are relevant
        */
        
        // Set stall signal high in the case of a lw stall...
        if (
          ((EX_instr_opcode_ip == OPCODE_LOAD) && (src1 == e_rd) && (src1 != 5'b0))
          || ((EX_instr_opcode_ip == OPCODE_LOAD) && (src2 == e_rd) && (src2 != 5'b0)) // If instruction in EX stage is a lw, and one of the src regs matches the dest reg from EX
        ) begin
            stall_op = 1'b1;
        end
        // ... or a wb stall
        else if (
          ((src1 == wb_rd) && (src1 != 5'b0) && (src1 != m_rd) && (src1 != e_rd))     // If one of the src regs matches the dest reg in the wb stage
          || ((src2 == wb_rd) && (src2 != 5'b0) && (src2 != m_rd) && (src2 != e_rd))
        ) begin
            stall_op = 1'b1;
        end

      end

      OPCODE_OPIMM: begin

        /**
        * Task 1
        * 
        * Here you will need to decide when to pull the stall control logic high. 
        * 
        * 1. Load to use stalls
        * 2. Stalls when reading and writing from Register File
        * For Register Immedite instructions, what registers are relevant
        */
        // Only need to check src1 in the case of an I-type instruction
        if (
          ((EX_instr_opcode_ip == OPCODE_LOAD) && (src1 == e_rd) && (src1 != 5'b0))
        ) begin
            stall_op = 1'b1;
        end
        else if (
          ((src1 == wb_rd) && (src1 != 5'b0) && (src1 != m_rd) && (src1 != e_rd))
        ) begin
            stall_op = 1'b1;
        end
      end

      default: begin
        stall_op = 1'b0;
      end
    endcase
  end

endmodule

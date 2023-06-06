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
//      Forward Controller for a 5 Stage RISCV Processor
//
//***********************************************************

import CORE_PKG::*;

module FWD_Control (
  input logic reset, 

  input [6:0] id_instr_opcode_ip, // ID/EX pipeline buffer opcode (to make sure the instruction requires source registers)

  input write_back_mux_selector EX_MEM_wb_mux_ip,
  input write_back_mux_selector MEM_WB_wb_mux_ip,

  input logic [4:0] EX_MEM_dest_ip, //EX/MEM Dest Register
  input logic [4:0] MEM_WB_dest_ip, //MEM/WB Dest Register
  input logic [4:0] ID_dest_rs1_ip, //R1 from decode stage
  input logic [4:0] ID_dest_rs2_ip, //R2 from decode stage

  output forward_mux_code fa_mux_op, //select lines for forwarding muxes (Rs)
  output forward_mux_code fb_mux_op  //select lines for forwarding muxes (Rt)
);

  // internal logic signals connected to reg addresses from different stages (to make conditional statements look cleaner)
  logic [4:0] em_rd;         
  logic [4:0] mwb_rd;
  logic [4:0] rs1;
  logic [4:0] rs2;
  assign em_rd = EX_MEM_dest_ip;
  assign mwb_rd = MEM_WB_dest_ip;
  assign rs1 = ID_dest_rs1_ip;
  assign rs2 = ID_dest_rs2_ip;
  
  logic EX_MEM_RegWrite_en;
  logic MEM_WB_RegWrite_en;

  assign EX_MEM_RegWrite_en = (EX_MEM_wb_mux_ip == NO_WRITEBACK) ? 1'b0 : 1'b1;
  assign MEM_WB_RegWrite_en = (MEM_WB_wb_mux_ip == NO_WRITEBACK) ? 1'b0 : 1'b1;

  always @(*) begin
    fa_mux_op = ORIGINAL_SELECT;
    fb_mux_op = ORIGINAL_SELECT;

    case (id_instr_opcode_ip)

      OPCODE_OP: begin // Register-Register ALU operation

        /**
        * Task 2
        * 
        * Here you will need to check for hazards and decide if and what you will forward 
        * For Register Register instructions, what registers are relevant for you to check 
        */
        
        // Check hazards between rs1 and either the ex_mem register or the mem_wb register
        if ((EX_MEM_RegWrite_en == 1) && (em_rd != 5'b0) && (em_rd == rs1)) begin // priority is a "younger" instruction
          fa_mux_op = EX_RESULT_SELECT;
        end
        else if ((MEM_WB_RegWrite_en == 1) && (mwb_rd != 5'b0) && (mwb_rd == rs1)) begin
          fa_mux_op = MEM_RESULT_SELECT;
        end

        // Check hazards between rs2 and wither the ex_mem register or the mem_wb register
        if ((EX_MEM_RegWrite_en == 1) && (em_rd != 5'b0) && (em_rd == rs2)) begin
          fb_mux_op = EX_RESULT_SELECT;
        end
        else if ((MEM_WB_RegWrite_en == 1) && (mwb_rd != 5'b0) && (mwb_rd == rs2)) begin
          fb_mux_op = MEM_RESULT_SELECT;
        end

      end

      OPCODE_OPIMM: begin // Register Immediate 

        /**
        * Task 2
        * 
        * Here you will need to check for hazards and decide if and what you will forward 
        * For Register Register instructions, what registers are relevant for you to check
        */

        // Only need to check rs1 because an I-type instr does not use a second src reg
        if ((EX_MEM_RegWrite_en == 1) && (em_rd != 5'b0) && (em_rd == rs1)) begin
          fa_mux_op = EX_RESULT_SELECT;
        end
        else if ((MEM_WB_RegWrite_en == 1) && (mwb_rd != 5'b0) && (mwb_rd == rs1)) begin
          fa_mux_op = MEM_RESULT_SELECT;
        end
      end

    endcase

  end
endmodule
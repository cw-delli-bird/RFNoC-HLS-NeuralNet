//
//    rfnoc-hls-neuralnet: Vivado HLS code for neural-net building blocks
//
//    Copyright (C) 2017 EJ Kreinar
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

module nnet_vector_wrapper #(
  parameter WIDTH = 16,
  parameter HEADER_WIDTH = 128, 
  parameter HEADER_FIFO_SIZE = 3
)(
  input clk, input reset, input clear,
  input [15:0] next_dst_sid,
  input [15:0] pkt_size_in, pkt_size_out,

  // AXI Interface from axi_wrapper
  input [2*WIDTH-1:0] i_tdata, input i_tlast, input i_tvalid, output i_tready, input [HEADER_WIDTH-1:0] i_tuser,
  output [2*WIDTH-1:0] o_tdata, output o_tlast, output o_tvalid, input o_tready, output [HEADER_WIDTH-1:0] o_tuser,

  // AXI Interface to user code
  output [2*WIDTH-1:0] m_axis_data_tdata, output m_axis_data_tlast, output m_axis_data_tvalid, input m_axis_data_tready,
  input [2*WIDTH-1:0] s_axis_data_tdata, input s_axis_data_tlast, input s_axis_data_tvalid, output s_axis_data_tready
);

  wire [HEADER_WIDTH-1:0] m_axis_data_tuser;

  packet_resizer_variable inst_packet_resizer_in (
    .clk(clk), .reset(reset | clear),
    .next_dst_sid(next_dst_sid),
    .pkt_size(pkt_size_in),
    .i_tdata(i_tdata), .i_tuser(i_tuser),
    .i_tlast(i_tlast), .i_tvalid(i_tvalid), .i_tready(i_tready),
    .o_tdata(m_axis_data_tdata), .o_tuser(m_axis_data_tuser),
    .o_tlast(m_axis_data_tlast), .o_tvalid(m_axis_data_tvalid), .o_tready(m_axis_data_tready));

  reg sof_in  = 1'b1;
  reg sof_out = 1'b1;
  always @(posedge clk) begin
    if (reset | clear) begin
      sof_in     <= 1'b1;
      sof_out    <= 1'b1;
    end else begin
      if (m_axis_data_tvalid & m_axis_data_tready) begin
        if (m_axis_data_tlast) begin
          sof_in  <= 1'b1;
        end else begin
          sof_in  <= 1'b0;
        end
      end
      if (o_tvalid & o_tready) begin
        if (o_tlast) begin
          sof_out  <= 1'b1;
        end else begin
          sof_out  <= 1'b0;
        end
      end
    end
  end

  wire [127:0] hdr_tuser_int;
  wire hdr_tuser_valid = sof_in & m_axis_data_tvalid & m_axis_data_tready;
  wire hdr_tuser_ready = sof_out & o_tvalid & o_tready;

  axi_fifo #(
    .WIDTH(HEADER_WIDTH), .SIZE(HEADER_FIFO_SIZE))
  axi_fifo_header (
    .clk(clk), .reset(reset), .clear(clear),
    .i_tdata(m_axis_data_tuser),
    .i_tvalid(hdr_tuser_valid), .i_tready(),
    .o_tdata(hdr_tuser_int),
    .o_tvalid(), .o_tready(hdr_tuser_ready), // Consume header on last output sample
    .space(), .occupied());


  packet_resizer_variable inst_packet_resizer_out (
    .clk(clk), .reset(reset | clear),
    .next_dst_sid(next_dst_sid),
    .pkt_size(pkt_size_out),
    .i_tdata(s_axis_data_tdata), .i_tuser(hdr_tuser_int),
    .i_tlast(s_axis_data_tlast), .i_tvalid(s_axis_data_tvalid), .i_tready(s_axis_data_tready),
    .o_tdata(o_tdata), .o_tuser(o_tuser),
    .o_tlast(o_tlast), .o_tvalid(o_tvalid), .o_tready(o_tready));


endmodule

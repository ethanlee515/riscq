// Generator : SpinalHDL dev    git head : 196c88c250c8a53da425b2e185580e43b8edc1c5
// Component : AxiToTileLinkMem
// Git hash  : febadb68d0e4ae36c7b6dfac1793cfd41024899a

`timescale 1ns/1ps

module AxiToTileLinkMem (
  input  wire          AXI_AWVALID,
  output wire          AXI_AWREADY,
  input  wire [31:0]   AXI_AWADDR,
  input  wire [3:0]    AXI_AWID,
  input  wire [3:0]    AXI_AWREGION,
  input  wire [7:0]    AXI_AWLEN,
  input  wire [2:0]    AXI_AWSIZE,
  input  wire [1:0]    AXI_AWBURST,
  input  wire [0:0]    AXI_AWLOCK,
  input  wire [3:0]    AXI_AWCACHE,
  input  wire [3:0]    AXI_AWQOS,
  input  wire [2:0]    AXI_AWPROT,
  input  wire          AXI_WVALID,
  output wire          AXI_WREADY,
  input  wire [31:0]   AXI_WDATA,
  input  wire [3:0]    AXI_WSTRB,
  input  wire          AXI_WLAST,
  output wire          AXI_BVALID,
  input  wire          AXI_BREADY,
  output wire [3:0]    AXI_BID,
  output wire [1:0]    AXI_BRESP,
  input  wire          AXI_ARVALID,
  output wire          AXI_ARREADY,
  input  wire [31:0]   AXI_ARADDR,
  input  wire [3:0]    AXI_ARID,
  input  wire [3:0]    AXI_ARREGION,
  input  wire [7:0]    AXI_ARLEN,
  input  wire [2:0]    AXI_ARSIZE,
  input  wire [1:0]    AXI_ARBURST,
  input  wire [0:0]    AXI_ARLOCK,
  input  wire [3:0]    AXI_ARCACHE,
  input  wire [3:0]    AXI_ARQOS,
  input  wire [2:0]    AXI_ARPROT,
  output wire          AXI_RVALID,
  input  wire          AXI_RREADY,
  output wire [31:0]   AXI_RDATA,
  output wire [3:0]    AXI_RID,
  output wire [1:0]    AXI_RRESP,
  output wire          AXI_RLAST,
  input  wire          clk,
  input  wire          reset
);
  localparam A_PUT_FULL_DATA = 3'd0;
  localparam A_PUT_PARTIAL_DATA = 3'd1;
  localparam A_GET = 3'd4;
  localparam A_ACQUIRE_BLOCK = 3'd6;
  localparam A_ACQUIRE_PERM = 3'd7;
  localparam D_ACCESS_ACK = 3'd0;
  localparam D_ACCESS_ACK_DATA = 3'd1;
  localparam D_GRANT = 3'd4;
  localparam D_GRANT_DATA = 3'd5;
  localparam D_RELEASE_ACK = 3'd6;

  reg        [127:0]  mem_spinal_port0;
  wire                bridge_read_bridge_io_up_ar_ready;
  wire                bridge_read_bridge_io_up_r_valid;
  wire       [31:0]   bridge_read_bridge_io_up_r_payload_data;
  wire       [3:0]    bridge_read_bridge_io_up_r_payload_id;
  wire       [1:0]    bridge_read_bridge_io_up_r_payload_resp;
  wire                bridge_read_bridge_io_up_r_payload_last;
  wire                bridge_read_bridge_io_down_a_valid;
  wire       [2:0]    bridge_read_bridge_io_down_a_payload_opcode;
  wire       [2:0]    bridge_read_bridge_io_down_a_payload_param;
  wire       [1:0]    bridge_read_bridge_io_down_a_payload_source;
  wire       [31:0]   bridge_read_bridge_io_down_a_payload_address;
  wire       [2:0]    bridge_read_bridge_io_down_a_payload_size;
  wire                bridge_read_bridge_io_down_d_ready;
  wire                bridge_write_bridge_io_up_aw_ready;
  wire                bridge_write_bridge_io_up_w_ready;
  wire                bridge_write_bridge_io_up_b_valid;
  wire       [3:0]    bridge_write_bridge_io_up_b_payload_id;
  wire       [1:0]    bridge_write_bridge_io_up_b_payload_resp;
  wire                bridge_write_bridge_io_down_a_valid;
  wire       [2:0]    bridge_write_bridge_io_down_a_payload_opcode;
  wire       [2:0]    bridge_write_bridge_io_down_a_payload_param;
  wire       [1:0]    bridge_write_bridge_io_down_a_payload_source;
  wire       [31:0]   bridge_write_bridge_io_down_a_payload_address;
  wire       [2:0]    bridge_write_bridge_io_down_a_payload_size;
  wire       [3:0]    bridge_write_bridge_io_down_a_payload_mask;
  wire       [31:0]   bridge_write_bridge_io_down_a_payload_data;
  wire                bridge_write_bridge_io_down_a_payload_corrupt;
  wire                bridge_write_bridge_io_down_d_ready;
  wire                bridge_down_arbiter_core_io_ups_0_a_ready;
  wire                bridge_down_arbiter_core_io_ups_0_d_valid;
  wire       [2:0]    bridge_down_arbiter_core_io_ups_0_d_payload_opcode;
  wire       [2:0]    bridge_down_arbiter_core_io_ups_0_d_payload_param;
  wire       [1:0]    bridge_down_arbiter_core_io_ups_0_d_payload_source;
  wire       [2:0]    bridge_down_arbiter_core_io_ups_0_d_payload_size;
  wire                bridge_down_arbiter_core_io_ups_0_d_payload_denied;
  wire       [127:0]  bridge_down_arbiter_core_io_ups_0_d_payload_data;
  wire                bridge_down_arbiter_core_io_ups_0_d_payload_corrupt;
  wire                bridge_down_arbiter_core_io_ups_1_a_ready;
  wire                bridge_down_arbiter_core_io_ups_1_d_valid;
  wire       [2:0]    bridge_down_arbiter_core_io_ups_1_d_payload_opcode;
  wire       [2:0]    bridge_down_arbiter_core_io_ups_1_d_payload_param;
  wire       [1:0]    bridge_down_arbiter_core_io_ups_1_d_payload_source;
  wire       [2:0]    bridge_down_arbiter_core_io_ups_1_d_payload_size;
  wire                bridge_down_arbiter_core_io_ups_1_d_payload_denied;
  wire                bridge_down_arbiter_core_io_down_a_valid;
  wire       [2:0]    bridge_down_arbiter_core_io_down_a_payload_opcode;
  wire       [2:0]    bridge_down_arbiter_core_io_down_a_payload_param;
  wire       [2:0]    bridge_down_arbiter_core_io_down_a_payload_source;
  wire       [13:0]   bridge_down_arbiter_core_io_down_a_payload_address;
  wire       [2:0]    bridge_down_arbiter_core_io_down_a_payload_size;
  wire       [15:0]   bridge_down_arbiter_core_io_down_a_payload_mask;
  wire       [127:0]  bridge_down_arbiter_core_io_down_a_payload_data;
  wire                bridge_down_arbiter_core_io_down_a_payload_corrupt;
  wire                bridge_down_arbiter_core_io_down_d_ready;
  wire                bridge_downRead_to_bridge_down_widthAdapter_io_up_a_ready;
  wire                bridge_downRead_to_bridge_down_widthAdapter_io_up_d_valid;
  wire       [2:0]    bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_opcode;
  wire       [2:0]    bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_param;
  wire       [1:0]    bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_source;
  wire       [2:0]    bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_size;
  wire                bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_denied;
  wire       [31:0]   bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_data;
  wire                bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_corrupt;
  wire                bridge_downRead_to_bridge_down_widthAdapter_io_down_a_valid;
  wire       [2:0]    bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_opcode;
  wire       [2:0]    bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_param;
  wire       [1:0]    bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_source;
  wire       [13:0]   bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_address;
  wire       [2:0]    bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_size;
  wire                bridge_downRead_to_bridge_down_widthAdapter_io_down_d_ready;
  wire                bridge_downWrite_to_bridge_down_widthAdapter_io_up_a_ready;
  wire                bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_valid;
  wire       [2:0]    bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_opcode;
  wire       [2:0]    bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_param;
  wire       [1:0]    bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_source;
  wire       [2:0]    bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_size;
  wire                bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_denied;
  wire                bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_valid;
  wire       [2:0]    bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_opcode;
  wire       [2:0]    bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_param;
  wire       [1:0]    bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_source;
  wire       [13:0]   bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_address;
  wire       [2:0]    bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_size;
  wire       [15:0]   bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_mask;
  wire       [127:0]  bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_data;
  wire                bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_corrupt;
  wire                bridge_downWrite_to_bridge_down_widthAdapter_io_down_d_ready;
  reg        [0:0]    _zz_when_TileLinkAccess_l64;
  wire       [9:0]    _zz__zz_memFiber_thread_logic_io_up_d_payload_data;
  reg        [0:0]    _zz_memFiber_thread_logic_io_up_a_tracker_last;
  wire       [7:0]    _zz_memFiber_thread_logic_ordering_payload_bytes;
  reg                 memFiber_thread_logic_pipeline_rsp_ready;
  reg        [2:0]    memFiber_thread_logic_pipeline_rsp_cmd_SIZE;
  reg        [2:0]    memFiber_thread_logic_pipeline_rsp_cmd_SOURCE;
  reg                 memFiber_thread_logic_pipeline_rsp_cmd_IS_GET;
  reg                 memFiber_thread_logic_pipeline_rsp_cmd_LAST;
  wire                memFiber_thread_logic_pipeline_cmd_ready;
  reg                 memFiber_thread_logic_pipeline_cmd_LAST;
  reg        [2:0]    memFiber_thread_logic_pipeline_cmd_SOURCE;
  reg        [2:0]    memFiber_thread_logic_pipeline_cmd_SIZE;
  reg                 memFiber_thread_logic_pipeline_cmd_IS_GET;
  wire       [9:0]    _zz_memFiber_thread_logic_io_up_d_payload_data;
  wire                _zz_memFiber_thread_logic_io_up_d_payload_data_1;
  wire                _zz_memFiber_thread_logic_io_up_d_payload_data_2;
  wire       [15:0]   _zz_memFiber_thread_logic_io_up_d_payload_data_3;
  wire       [127:0]  _zz_memFiber_thread_logic_io_up_d_payload_data_4;
  wire                bridge_downRead_bus_a_valid;
  wire                bridge_downRead_bus_a_ready;
  wire       [2:0]    bridge_downRead_bus_a_payload_opcode;
  wire       [2:0]    bridge_downRead_bus_a_payload_param;
  wire       [1:0]    bridge_downRead_bus_a_payload_source;
  wire       [31:0]   bridge_downRead_bus_a_payload_address;
  wire       [2:0]    bridge_downRead_bus_a_payload_size;
  wire                bridge_downRead_bus_d_valid;
  wire                bridge_downRead_bus_d_ready;
  wire       [2:0]    bridge_downRead_bus_d_payload_opcode;
  wire       [2:0]    bridge_downRead_bus_d_payload_param;
  wire       [1:0]    bridge_downRead_bus_d_payload_source;
  wire       [2:0]    bridge_downRead_bus_d_payload_size;
  wire                bridge_downRead_bus_d_payload_denied;
  wire       [31:0]   bridge_downRead_bus_d_payload_data;
  wire                bridge_downRead_bus_d_payload_corrupt;
  wire                bridge_downRead_noDecoder_toDown_a_valid;
  wire                bridge_downRead_noDecoder_toDown_a_ready;
  wire       [2:0]    bridge_downRead_noDecoder_toDown_a_payload_opcode;
  wire       [2:0]    bridge_downRead_noDecoder_toDown_a_payload_param;
  wire       [1:0]    bridge_downRead_noDecoder_toDown_a_payload_source;
  wire       [31:0]   bridge_downRead_noDecoder_toDown_a_payload_address;
  wire       [2:0]    bridge_downRead_noDecoder_toDown_a_payload_size;
  wire                bridge_downRead_noDecoder_toDown_d_valid;
  wire                bridge_downRead_noDecoder_toDown_d_ready;
  wire       [2:0]    bridge_downRead_noDecoder_toDown_d_payload_opcode;
  wire       [2:0]    bridge_downRead_noDecoder_toDown_d_payload_param;
  wire       [1:0]    bridge_downRead_noDecoder_toDown_d_payload_source;
  wire       [2:0]    bridge_downRead_noDecoder_toDown_d_payload_size;
  wire                bridge_downRead_noDecoder_toDown_d_payload_denied;
  wire       [31:0]   bridge_downRead_noDecoder_toDown_d_payload_data;
  wire                bridge_downRead_noDecoder_toDown_d_payload_corrupt;
  wire                bridge_downWrite_bus_a_valid;
  wire                bridge_downWrite_bus_a_ready;
  wire       [2:0]    bridge_downWrite_bus_a_payload_opcode;
  wire       [2:0]    bridge_downWrite_bus_a_payload_param;
  wire       [1:0]    bridge_downWrite_bus_a_payload_source;
  wire       [31:0]   bridge_downWrite_bus_a_payload_address;
  wire       [2:0]    bridge_downWrite_bus_a_payload_size;
  wire       [3:0]    bridge_downWrite_bus_a_payload_mask;
  wire       [31:0]   bridge_downWrite_bus_a_payload_data;
  wire                bridge_downWrite_bus_a_payload_corrupt;
  wire                bridge_downWrite_bus_d_valid;
  wire                bridge_downWrite_bus_d_ready;
  wire       [2:0]    bridge_downWrite_bus_d_payload_opcode;
  wire       [2:0]    bridge_downWrite_bus_d_payload_param;
  wire       [1:0]    bridge_downWrite_bus_d_payload_source;
  wire       [2:0]    bridge_downWrite_bus_d_payload_size;
  wire                bridge_downWrite_bus_d_payload_denied;
  wire                bridge_downWrite_noDecoder_toDown_a_valid;
  wire                bridge_downWrite_noDecoder_toDown_a_ready;
  wire       [2:0]    bridge_downWrite_noDecoder_toDown_a_payload_opcode;
  wire       [2:0]    bridge_downWrite_noDecoder_toDown_a_payload_param;
  wire       [1:0]    bridge_downWrite_noDecoder_toDown_a_payload_source;
  wire       [31:0]   bridge_downWrite_noDecoder_toDown_a_payload_address;
  wire       [2:0]    bridge_downWrite_noDecoder_toDown_a_payload_size;
  wire       [3:0]    bridge_downWrite_noDecoder_toDown_a_payload_mask;
  wire       [31:0]   bridge_downWrite_noDecoder_toDown_a_payload_data;
  wire                bridge_downWrite_noDecoder_toDown_a_payload_corrupt;
  wire                bridge_downWrite_noDecoder_toDown_d_valid;
  wire                bridge_downWrite_noDecoder_toDown_d_ready;
  wire       [2:0]    bridge_downWrite_noDecoder_toDown_d_payload_opcode;
  wire       [2:0]    bridge_downWrite_noDecoder_toDown_d_payload_param;
  wire       [1:0]    bridge_downWrite_noDecoder_toDown_d_payload_source;
  wire       [2:0]    bridge_downWrite_noDecoder_toDown_d_payload_size;
  wire                bridge_downWrite_noDecoder_toDown_d_payload_denied;
  wire                bridge_down_bus_a_valid;
  wire                bridge_down_bus_a_ready;
  wire       [2:0]    bridge_down_bus_a_payload_opcode;
  wire       [2:0]    bridge_down_bus_a_payload_param;
  wire       [2:0]    bridge_down_bus_a_payload_source;
  wire       [13:0]   bridge_down_bus_a_payload_address;
  wire       [2:0]    bridge_down_bus_a_payload_size;
  wire       [15:0]   bridge_down_bus_a_payload_mask;
  wire       [127:0]  bridge_down_bus_a_payload_data;
  wire                bridge_down_bus_a_payload_corrupt;
  wire                bridge_down_bus_d_valid;
  wire                bridge_down_bus_d_ready;
  wire       [2:0]    bridge_down_bus_d_payload_opcode;
  wire       [2:0]    bridge_down_bus_d_payload_param;
  wire       [2:0]    bridge_down_bus_d_payload_source;
  wire       [2:0]    bridge_down_bus_d_payload_size;
  wire                bridge_down_bus_d_payload_denied;
  wire       [127:0]  bridge_down_bus_d_payload_data;
  wire                bridge_down_bus_d_payload_corrupt;
  wire                bridge_downRead_to_bridge_down_down_bus_a_valid;
  wire                bridge_downRead_to_bridge_down_down_bus_a_ready;
  wire       [2:0]    bridge_downRead_to_bridge_down_down_bus_a_payload_opcode;
  wire       [2:0]    bridge_downRead_to_bridge_down_down_bus_a_payload_param;
  wire       [1:0]    bridge_downRead_to_bridge_down_down_bus_a_payload_source;
  wire       [13:0]   bridge_downRead_to_bridge_down_down_bus_a_payload_address;
  wire       [2:0]    bridge_downRead_to_bridge_down_down_bus_a_payload_size;
  wire                bridge_downRead_to_bridge_down_down_bus_d_valid;
  wire                bridge_downRead_to_bridge_down_down_bus_d_ready;
  wire       [2:0]    bridge_downRead_to_bridge_down_down_bus_d_payload_opcode;
  wire       [2:0]    bridge_downRead_to_bridge_down_down_bus_d_payload_param;
  wire       [1:0]    bridge_downRead_to_bridge_down_down_bus_d_payload_source;
  wire       [2:0]    bridge_downRead_to_bridge_down_down_bus_d_payload_size;
  wire                bridge_downRead_to_bridge_down_down_bus_d_payload_denied;
  wire       [127:0]  bridge_downRead_to_bridge_down_down_bus_d_payload_data;
  wire                bridge_downRead_to_bridge_down_down_bus_d_payload_corrupt;
  wire                bridge_downWrite_to_bridge_down_down_bus_a_valid;
  wire                bridge_downWrite_to_bridge_down_down_bus_a_ready;
  wire       [2:0]    bridge_downWrite_to_bridge_down_down_bus_a_payload_opcode;
  wire       [2:0]    bridge_downWrite_to_bridge_down_down_bus_a_payload_param;
  wire       [1:0]    bridge_downWrite_to_bridge_down_down_bus_a_payload_source;
  wire       [13:0]   bridge_downWrite_to_bridge_down_down_bus_a_payload_address;
  wire       [2:0]    bridge_downWrite_to_bridge_down_down_bus_a_payload_size;
  wire       [15:0]   bridge_downWrite_to_bridge_down_down_bus_a_payload_mask;
  wire       [127:0]  bridge_downWrite_to_bridge_down_down_bus_a_payload_data;
  wire                bridge_downWrite_to_bridge_down_down_bus_a_payload_corrupt;
  wire                bridge_downWrite_to_bridge_down_down_bus_d_valid;
  wire                bridge_downWrite_to_bridge_down_down_bus_d_ready;
  wire       [2:0]    bridge_downWrite_to_bridge_down_down_bus_d_payload_opcode;
  wire       [2:0]    bridge_downWrite_to_bridge_down_down_bus_d_payload_param;
  wire       [1:0]    bridge_downWrite_to_bridge_down_down_bus_d_payload_source;
  wire       [2:0]    bridge_downWrite_to_bridge_down_down_bus_d_payload_size;
  wire                bridge_downWrite_to_bridge_down_down_bus_d_payload_denied;
  wire                bridge_down_noDecoder_toDown_a_valid;
  wire                bridge_down_noDecoder_toDown_a_ready;
  wire       [2:0]    bridge_down_noDecoder_toDown_a_payload_opcode;
  wire       [2:0]    bridge_down_noDecoder_toDown_a_payload_param;
  wire       [2:0]    bridge_down_noDecoder_toDown_a_payload_source;
  wire       [13:0]   bridge_down_noDecoder_toDown_a_payload_address;
  wire       [2:0]    bridge_down_noDecoder_toDown_a_payload_size;
  wire       [15:0]   bridge_down_noDecoder_toDown_a_payload_mask;
  wire       [127:0]  bridge_down_noDecoder_toDown_a_payload_data;
  wire                bridge_down_noDecoder_toDown_a_payload_corrupt;
  wire                bridge_down_noDecoder_toDown_d_valid;
  wire                bridge_down_noDecoder_toDown_d_ready;
  wire       [2:0]    bridge_down_noDecoder_toDown_d_payload_opcode;
  wire       [2:0]    bridge_down_noDecoder_toDown_d_payload_param;
  wire       [2:0]    bridge_down_noDecoder_toDown_d_payload_source;
  wire       [2:0]    bridge_down_noDecoder_toDown_d_payload_size;
  wire                bridge_down_noDecoder_toDown_d_payload_denied;
  wire       [127:0]  bridge_down_noDecoder_toDown_d_payload_data;
  wire                bridge_down_noDecoder_toDown_d_payload_corrupt;
  wire                memFiber_up_bus_a_valid;
  wire                memFiber_up_bus_a_ready;
  wire       [2:0]    memFiber_up_bus_a_payload_opcode;
  wire       [2:0]    memFiber_up_bus_a_payload_param;
  wire       [2:0]    memFiber_up_bus_a_payload_source;
  wire       [13:0]   memFiber_up_bus_a_payload_address;
  wire       [2:0]    memFiber_up_bus_a_payload_size;
  wire       [15:0]   memFiber_up_bus_a_payload_mask;
  wire       [127:0]  memFiber_up_bus_a_payload_data;
  wire                memFiber_up_bus_a_payload_corrupt;
  wire                memFiber_up_bus_d_valid;
  wire                memFiber_up_bus_d_ready;
  wire       [2:0]    memFiber_up_bus_d_payload_opcode;
  wire       [2:0]    memFiber_up_bus_d_payload_param;
  wire       [2:0]    memFiber_up_bus_d_payload_source;
  wire       [2:0]    memFiber_up_bus_d_payload_size;
  wire                memFiber_up_bus_d_payload_denied;
  wire       [127:0]  memFiber_up_bus_d_payload_data;
  wire                memFiber_up_bus_d_payload_corrupt;
  wire                bridge_down_to_memFiber_up_down_bus_a_valid;
  wire                bridge_down_to_memFiber_up_down_bus_a_ready;
  wire       [2:0]    bridge_down_to_memFiber_up_down_bus_a_payload_opcode;
  wire       [2:0]    bridge_down_to_memFiber_up_down_bus_a_payload_param;
  wire       [2:0]    bridge_down_to_memFiber_up_down_bus_a_payload_source;
  wire       [13:0]   bridge_down_to_memFiber_up_down_bus_a_payload_address;
  wire       [2:0]    bridge_down_to_memFiber_up_down_bus_a_payload_size;
  wire       [15:0]   bridge_down_to_memFiber_up_down_bus_a_payload_mask;
  wire       [127:0]  bridge_down_to_memFiber_up_down_bus_a_payload_data;
  wire                bridge_down_to_memFiber_up_down_bus_a_payload_corrupt;
  wire                bridge_down_to_memFiber_up_down_bus_d_valid;
  wire                bridge_down_to_memFiber_up_down_bus_d_ready;
  wire       [2:0]    bridge_down_to_memFiber_up_down_bus_d_payload_opcode;
  wire       [2:0]    bridge_down_to_memFiber_up_down_bus_d_payload_param;
  wire       [2:0]    bridge_down_to_memFiber_up_down_bus_d_payload_source;
  wire       [2:0]    bridge_down_to_memFiber_up_down_bus_d_payload_size;
  wire                bridge_down_to_memFiber_up_down_bus_d_payload_denied;
  wire       [127:0]  bridge_down_to_memFiber_up_down_bus_d_payload_data;
  wire                bridge_down_to_memFiber_up_down_bus_d_payload_corrupt;
  wire                bridge_downRead_to_bridge_down_up_bus_a_valid;
  wire                bridge_downRead_to_bridge_down_up_bus_a_ready;
  wire       [2:0]    bridge_downRead_to_bridge_down_up_bus_a_payload_opcode;
  wire       [2:0]    bridge_downRead_to_bridge_down_up_bus_a_payload_param;
  wire       [1:0]    bridge_downRead_to_bridge_down_up_bus_a_payload_source;
  wire       [13:0]   bridge_downRead_to_bridge_down_up_bus_a_payload_address;
  wire       [2:0]    bridge_downRead_to_bridge_down_up_bus_a_payload_size;
  wire                bridge_downRead_to_bridge_down_up_bus_d_valid;
  wire                bridge_downRead_to_bridge_down_up_bus_d_ready;
  wire       [2:0]    bridge_downRead_to_bridge_down_up_bus_d_payload_opcode;
  wire       [2:0]    bridge_downRead_to_bridge_down_up_bus_d_payload_param;
  wire       [1:0]    bridge_downRead_to_bridge_down_up_bus_d_payload_source;
  wire       [2:0]    bridge_downRead_to_bridge_down_up_bus_d_payload_size;
  wire                bridge_downRead_to_bridge_down_up_bus_d_payload_denied;
  wire       [31:0]   bridge_downRead_to_bridge_down_up_bus_d_payload_data;
  wire                bridge_downRead_to_bridge_down_up_bus_d_payload_corrupt;
  wire                bridge_downWrite_to_bridge_down_up_bus_a_valid;
  wire                bridge_downWrite_to_bridge_down_up_bus_a_ready;
  wire       [2:0]    bridge_downWrite_to_bridge_down_up_bus_a_payload_opcode;
  wire       [2:0]    bridge_downWrite_to_bridge_down_up_bus_a_payload_param;
  wire       [1:0]    bridge_downWrite_to_bridge_down_up_bus_a_payload_source;
  wire       [13:0]   bridge_downWrite_to_bridge_down_up_bus_a_payload_address;
  wire       [2:0]    bridge_downWrite_to_bridge_down_up_bus_a_payload_size;
  wire       [3:0]    bridge_downWrite_to_bridge_down_up_bus_a_payload_mask;
  wire       [31:0]   bridge_downWrite_to_bridge_down_up_bus_a_payload_data;
  wire                bridge_downWrite_to_bridge_down_up_bus_a_payload_corrupt;
  wire                bridge_downWrite_to_bridge_down_up_bus_d_valid;
  wire                bridge_downWrite_to_bridge_down_up_bus_d_ready;
  wire       [2:0]    bridge_downWrite_to_bridge_down_up_bus_d_payload_opcode;
  wire       [2:0]    bridge_downWrite_to_bridge_down_up_bus_d_payload_param;
  wire       [1:0]    bridge_downWrite_to_bridge_down_up_bus_d_payload_source;
  wire       [2:0]    bridge_downWrite_to_bridge_down_up_bus_d_payload_size;
  wire                bridge_downWrite_to_bridge_down_up_bus_d_payload_denied;
  wire                memFiber_thread_logic_io_up_a_valid;
  reg                 memFiber_thread_logic_io_up_a_ready;
  wire       [2:0]    memFiber_thread_logic_io_up_a_payload_opcode;
  wire       [2:0]    memFiber_thread_logic_io_up_a_payload_param;
  wire       [2:0]    memFiber_thread_logic_io_up_a_payload_source;
  wire       [13:0]   memFiber_thread_logic_io_up_a_payload_address;
  wire       [2:0]    memFiber_thread_logic_io_up_a_payload_size;
  wire       [15:0]   memFiber_thread_logic_io_up_a_payload_mask;
  wire       [127:0]  memFiber_thread_logic_io_up_a_payload_data;
  wire                memFiber_thread_logic_io_up_a_payload_corrupt;
  wire                memFiber_thread_logic_io_up_d_valid;
  wire                memFiber_thread_logic_io_up_d_ready;
  wire       [2:0]    memFiber_thread_logic_io_up_d_payload_opcode;
  wire       [2:0]    memFiber_thread_logic_io_up_d_payload_param;
  wire       [2:0]    memFiber_thread_logic_io_up_d_payload_source;
  wire       [2:0]    memFiber_thread_logic_io_up_d_payload_size;
  wire                memFiber_thread_logic_io_up_d_payload_denied;
  wire       [127:0]  memFiber_thread_logic_io_up_d_payload_data;
  wire                memFiber_thread_logic_io_up_d_payload_corrupt;
  reg                 memFiber_thread_logic_pipeline_cmd_valid;
  wire       [9:0]    memFiber_thread_logic_pipeline_cmd_addressShifted;
  wire                memFiber_thread_logic_pipeline_cmd_isFireing;
  reg        [0:0]    memFiber_thread_logic_pipeline_cmd_fsm_counter;
  reg        [9:0]    memFiber_thread_logic_pipeline_cmd_fsm_address;
  reg        [2:0]    memFiber_thread_logic_pipeline_cmd_fsm_size;
  reg        [2:0]    memFiber_thread_logic_pipeline_cmd_fsm_source;
  reg                 memFiber_thread_logic_pipeline_cmd_fsm_isGet;
  wire                memFiber_thread_logic_pipeline_cmd_fsm_busy;
  wire                when_TileLinkAccess_l52;
  wire                memFiber_thread_logic_io_up_a_fire;
  wire                when_TileLinkAccess_l57;
  wire                when_TileLinkAccess_l64;
  reg                 memFiber_thread_logic_pipeline_rsp_valid;
  wire                memFiber_thread_logic_pipeline_rsp_takeIt;
  wire                memFiber_thread_logic_pipeline_rsp_haltRequest_TileLinkAccess_l83;
  wire       [2:0]    _zz_memFiber_thread_logic_io_up_d_payload_opcode;
  reg                 memFiber_thread_logic_pipeline_cmd_ready_output;
  wire                when_Pipeline_l278;
  wire                when_Connection_l74;
  wire                memFiber_thread_logic_ordering_valid;
  wire       [5:0]    memFiber_thread_logic_ordering_payload_bytes;
  reg        [0:0]    memFiber_thread_logic_io_up_a_tracker_beat;
  wire                memFiber_thread_logic_io_up_a_tracker_last;
  reg                 memFiber_thread_logic_ordering_regNext_valid;
  reg        [5:0]    memFiber_thread_logic_ordering_regNext_payload_bytes;
  wire                bridge_down_to_memFiber_up_up_bus_a_valid;
  wire                bridge_down_to_memFiber_up_up_bus_a_ready;
  wire       [2:0]    bridge_down_to_memFiber_up_up_bus_a_payload_opcode;
  wire       [2:0]    bridge_down_to_memFiber_up_up_bus_a_payload_param;
  wire       [2:0]    bridge_down_to_memFiber_up_up_bus_a_payload_source;
  wire       [13:0]   bridge_down_to_memFiber_up_up_bus_a_payload_address;
  wire       [2:0]    bridge_down_to_memFiber_up_up_bus_a_payload_size;
  wire       [15:0]   bridge_down_to_memFiber_up_up_bus_a_payload_mask;
  wire       [127:0]  bridge_down_to_memFiber_up_up_bus_a_payload_data;
  wire                bridge_down_to_memFiber_up_up_bus_a_payload_corrupt;
  wire                bridge_down_to_memFiber_up_up_bus_d_valid;
  wire                bridge_down_to_memFiber_up_up_bus_d_ready;
  wire       [2:0]    bridge_down_to_memFiber_up_up_bus_d_payload_opcode;
  wire       [2:0]    bridge_down_to_memFiber_up_up_bus_d_payload_param;
  wire       [2:0]    bridge_down_to_memFiber_up_up_bus_d_payload_source;
  wire       [2:0]    bridge_down_to_memFiber_up_up_bus_d_payload_size;
  wire                bridge_down_to_memFiber_up_up_bus_d_payload_denied;
  wire       [127:0]  bridge_down_to_memFiber_up_up_bus_d_payload_data;
  wire                bridge_down_to_memFiber_up_up_bus_d_payload_corrupt;
  `ifndef SYNTHESIS
  reg [127:0] bridge_downRead_bus_a_payload_opcode_string;
  reg [119:0] bridge_downRead_bus_d_payload_opcode_string;
  reg [127:0] bridge_downRead_noDecoder_toDown_a_payload_opcode_string;
  reg [119:0] bridge_downRead_noDecoder_toDown_d_payload_opcode_string;
  reg [127:0] bridge_downWrite_bus_a_payload_opcode_string;
  reg [119:0] bridge_downWrite_bus_d_payload_opcode_string;
  reg [127:0] bridge_downWrite_noDecoder_toDown_a_payload_opcode_string;
  reg [119:0] bridge_downWrite_noDecoder_toDown_d_payload_opcode_string;
  reg [127:0] bridge_down_bus_a_payload_opcode_string;
  reg [119:0] bridge_down_bus_d_payload_opcode_string;
  reg [127:0] bridge_downRead_to_bridge_down_down_bus_a_payload_opcode_string;
  reg [119:0] bridge_downRead_to_bridge_down_down_bus_d_payload_opcode_string;
  reg [127:0] bridge_downWrite_to_bridge_down_down_bus_a_payload_opcode_string;
  reg [119:0] bridge_downWrite_to_bridge_down_down_bus_d_payload_opcode_string;
  reg [127:0] bridge_down_noDecoder_toDown_a_payload_opcode_string;
  reg [119:0] bridge_down_noDecoder_toDown_d_payload_opcode_string;
  reg [127:0] memFiber_up_bus_a_payload_opcode_string;
  reg [119:0] memFiber_up_bus_d_payload_opcode_string;
  reg [127:0] bridge_down_to_memFiber_up_down_bus_a_payload_opcode_string;
  reg [119:0] bridge_down_to_memFiber_up_down_bus_d_payload_opcode_string;
  reg [127:0] bridge_downRead_to_bridge_down_up_bus_a_payload_opcode_string;
  reg [119:0] bridge_downRead_to_bridge_down_up_bus_d_payload_opcode_string;
  reg [127:0] bridge_downWrite_to_bridge_down_up_bus_a_payload_opcode_string;
  reg [119:0] bridge_downWrite_to_bridge_down_up_bus_d_payload_opcode_string;
  reg [127:0] memFiber_thread_logic_io_up_a_payload_opcode_string;
  reg [119:0] memFiber_thread_logic_io_up_d_payload_opcode_string;
  reg [119:0] _zz_memFiber_thread_logic_io_up_d_payload_opcode_string;
  reg [127:0] bridge_down_to_memFiber_up_up_bus_a_payload_opcode_string;
  reg [119:0] bridge_down_to_memFiber_up_up_bus_d_payload_opcode_string;
  `endif

  reg [7:0] mem_symbol0 [0:1023];
  reg [7:0] mem_symbol1 [0:1023];
  reg [7:0] mem_symbol2 [0:1023];
  reg [7:0] mem_symbol3 [0:1023];
  reg [7:0] mem_symbol4 [0:1023];
  reg [7:0] mem_symbol5 [0:1023];
  reg [7:0] mem_symbol6 [0:1023];
  reg [7:0] mem_symbol7 [0:1023];
  reg [7:0] mem_symbol8 [0:1023];
  reg [7:0] mem_symbol9 [0:1023];
  reg [7:0] mem_symbol10 [0:1023];
  reg [7:0] mem_symbol11 [0:1023];
  reg [7:0] mem_symbol12 [0:1023];
  reg [7:0] mem_symbol13 [0:1023];
  reg [7:0] mem_symbol14 [0:1023];
  reg [7:0] mem_symbol15 [0:1023];
  reg [7:0] _zz_memsymbol_read;
  reg [7:0] _zz_memsymbol_read_1;
  reg [7:0] _zz_memsymbol_read_2;
  reg [7:0] _zz_memsymbol_read_3;
  reg [7:0] _zz_memsymbol_read_4;
  reg [7:0] _zz_memsymbol_read_5;
  reg [7:0] _zz_memsymbol_read_6;
  reg [7:0] _zz_memsymbol_read_7;
  reg [7:0] _zz_memsymbol_read_8;
  reg [7:0] _zz_memsymbol_read_9;
  reg [7:0] _zz_memsymbol_read_10;
  reg [7:0] _zz_memsymbol_read_11;
  reg [7:0] _zz_memsymbol_read_12;
  reg [7:0] _zz_memsymbol_read_13;
  reg [7:0] _zz_memsymbol_read_14;
  reg [7:0] _zz_memsymbol_read_15;

  assign _zz__zz_memFiber_thread_logic_io_up_d_payload_data = {9'd0, memFiber_thread_logic_pipeline_cmd_fsm_counter};
  assign _zz_memFiber_thread_logic_ordering_payload_bytes = ({7'd0,1'b1} <<< memFiber_thread_logic_io_up_a_payload_size);
  always @(*) begin
    mem_spinal_port0 = {_zz_memsymbol_read_15, _zz_memsymbol_read_14, _zz_memsymbol_read_13, _zz_memsymbol_read_12, _zz_memsymbol_read_11, _zz_memsymbol_read_10, _zz_memsymbol_read_9, _zz_memsymbol_read_8, _zz_memsymbol_read_7, _zz_memsymbol_read_6, _zz_memsymbol_read_5, _zz_memsymbol_read_4, _zz_memsymbol_read_3, _zz_memsymbol_read_2, _zz_memsymbol_read_1, _zz_memsymbol_read};
  end
  always @(posedge clk) begin
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_1) begin
      _zz_memsymbol_read <= mem_symbol0[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_1 <= mem_symbol1[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_2 <= mem_symbol2[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_3 <= mem_symbol3[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_4 <= mem_symbol4[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_5 <= mem_symbol5[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_6 <= mem_symbol6[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_7 <= mem_symbol7[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_8 <= mem_symbol8[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_9 <= mem_symbol9[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_10 <= mem_symbol10[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_11 <= mem_symbol11[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_12 <= mem_symbol12[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_13 <= mem_symbol13[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_14 <= mem_symbol14[_zz_memFiber_thread_logic_io_up_d_payload_data];
      _zz_memsymbol_read_15 <= mem_symbol15[_zz_memFiber_thread_logic_io_up_d_payload_data];
    end
  end

  always @(posedge clk) begin
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[0] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol0[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[7 : 0];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[1] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol1[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[15 : 8];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[2] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol2[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[23 : 16];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[3] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol3[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[31 : 24];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[4] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol4[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[39 : 32];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[5] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol5[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[47 : 40];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[6] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol6[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[55 : 48];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[7] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol7[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[63 : 56];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[8] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol8[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[71 : 64];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[9] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol9[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[79 : 72];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[10] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol10[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[87 : 80];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[11] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol11[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[95 : 88];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[12] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol12[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[103 : 96];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[13] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol13[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[111 : 104];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[14] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol14[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[119 : 112];
    end
    if(_zz_memFiber_thread_logic_io_up_d_payload_data_3[15] && _zz_memFiber_thread_logic_io_up_d_payload_data_1 && _zz_memFiber_thread_logic_io_up_d_payload_data_2 ) begin
      mem_symbol15[_zz_memFiber_thread_logic_io_up_d_payload_data] <= _zz_memFiber_thread_logic_io_up_d_payload_data_4[127 : 120];
    end
  end

  Axi4ReadOnlyToTilelinkFull bridge_read_bridge (
    .io_up_ar_valid            (AXI_ARVALID                                       ), //i
    .io_up_ar_ready            (bridge_read_bridge_io_up_ar_ready                 ), //o
    .io_up_ar_payload_addr     (AXI_ARADDR[31:0]                                  ), //i
    .io_up_ar_payload_id       (AXI_ARID[3:0]                                     ), //i
    .io_up_ar_payload_region   (AXI_ARREGION[3:0]                                 ), //i
    .io_up_ar_payload_len      (AXI_ARLEN[7:0]                                    ), //i
    .io_up_ar_payload_size     (AXI_ARSIZE[2:0]                                   ), //i
    .io_up_ar_payload_burst    (AXI_ARBURST[1:0]                                  ), //i
    .io_up_ar_payload_lock     (AXI_ARLOCK                                        ), //i
    .io_up_ar_payload_cache    (AXI_ARCACHE[3:0]                                  ), //i
    .io_up_ar_payload_qos      (AXI_ARQOS[3:0]                                    ), //i
    .io_up_ar_payload_prot     (AXI_ARPROT[2:0]                                   ), //i
    .io_up_r_valid             (bridge_read_bridge_io_up_r_valid                  ), //o
    .io_up_r_ready             (AXI_RREADY                                        ), //i
    .io_up_r_payload_data      (bridge_read_bridge_io_up_r_payload_data[31:0]     ), //o
    .io_up_r_payload_id        (bridge_read_bridge_io_up_r_payload_id[3:0]        ), //o
    .io_up_r_payload_resp      (bridge_read_bridge_io_up_r_payload_resp[1:0]      ), //o
    .io_up_r_payload_last      (bridge_read_bridge_io_up_r_payload_last           ), //o
    .io_down_a_valid           (bridge_read_bridge_io_down_a_valid                ), //o
    .io_down_a_ready           (bridge_downRead_bus_a_ready                       ), //i
    .io_down_a_payload_opcode  (bridge_read_bridge_io_down_a_payload_opcode[2:0]  ), //o
    .io_down_a_payload_param   (bridge_read_bridge_io_down_a_payload_param[2:0]   ), //o
    .io_down_a_payload_source  (bridge_read_bridge_io_down_a_payload_source[1:0]  ), //o
    .io_down_a_payload_address (bridge_read_bridge_io_down_a_payload_address[31:0]), //o
    .io_down_a_payload_size    (bridge_read_bridge_io_down_a_payload_size[2:0]    ), //o
    .io_down_d_valid           (bridge_downRead_bus_d_valid                       ), //i
    .io_down_d_ready           (bridge_read_bridge_io_down_d_ready                ), //o
    .io_down_d_payload_opcode  (bridge_downRead_bus_d_payload_opcode[2:0]         ), //i
    .io_down_d_payload_param   (bridge_downRead_bus_d_payload_param[2:0]          ), //i
    .io_down_d_payload_source  (bridge_downRead_bus_d_payload_source[1:0]         ), //i
    .io_down_d_payload_size    (bridge_downRead_bus_d_payload_size[2:0]           ), //i
    .io_down_d_payload_denied  (bridge_downRead_bus_d_payload_denied              ), //i
    .io_down_d_payload_data    (bridge_downRead_bus_d_payload_data[31:0]          ), //i
    .io_down_d_payload_corrupt (bridge_downRead_bus_d_payload_corrupt             ), //i
    .clk                       (clk                                               ), //i
    .reset                     (reset                                             )  //i
  );
  Axi4WriteOnlyToTilelinkFull bridge_write_bridge (
    .io_up_aw_valid            (AXI_AWVALID                                        ), //i
    .io_up_aw_ready            (bridge_write_bridge_io_up_aw_ready                 ), //o
    .io_up_aw_payload_addr     (AXI_AWADDR[31:0]                                   ), //i
    .io_up_aw_payload_id       (AXI_AWID[3:0]                                      ), //i
    .io_up_aw_payload_region   (AXI_AWREGION[3:0]                                  ), //i
    .io_up_aw_payload_len      (AXI_AWLEN[7:0]                                     ), //i
    .io_up_aw_payload_size     (AXI_AWSIZE[2:0]                                    ), //i
    .io_up_aw_payload_burst    (AXI_AWBURST[1:0]                                   ), //i
    .io_up_aw_payload_lock     (AXI_AWLOCK                                         ), //i
    .io_up_aw_payload_cache    (AXI_AWCACHE[3:0]                                   ), //i
    .io_up_aw_payload_qos      (AXI_AWQOS[3:0]                                     ), //i
    .io_up_aw_payload_prot     (AXI_AWPROT[2:0]                                    ), //i
    .io_up_w_valid             (AXI_WVALID                                         ), //i
    .io_up_w_ready             (bridge_write_bridge_io_up_w_ready                  ), //o
    .io_up_w_payload_data      (AXI_WDATA[31:0]                                    ), //i
    .io_up_w_payload_strb      (AXI_WSTRB[3:0]                                     ), //i
    .io_up_w_payload_last      (AXI_WLAST                                          ), //i
    .io_up_b_valid             (bridge_write_bridge_io_up_b_valid                  ), //o
    .io_up_b_ready             (AXI_BREADY                                         ), //i
    .io_up_b_payload_id        (bridge_write_bridge_io_up_b_payload_id[3:0]        ), //o
    .io_up_b_payload_resp      (bridge_write_bridge_io_up_b_payload_resp[1:0]      ), //o
    .io_down_a_valid           (bridge_write_bridge_io_down_a_valid                ), //o
    .io_down_a_ready           (bridge_downWrite_bus_a_ready                       ), //i
    .io_down_a_payload_opcode  (bridge_write_bridge_io_down_a_payload_opcode[2:0]  ), //o
    .io_down_a_payload_param   (bridge_write_bridge_io_down_a_payload_param[2:0]   ), //o
    .io_down_a_payload_source  (bridge_write_bridge_io_down_a_payload_source[1:0]  ), //o
    .io_down_a_payload_address (bridge_write_bridge_io_down_a_payload_address[31:0]), //o
    .io_down_a_payload_size    (bridge_write_bridge_io_down_a_payload_size[2:0]    ), //o
    .io_down_a_payload_mask    (bridge_write_bridge_io_down_a_payload_mask[3:0]    ), //o
    .io_down_a_payload_data    (bridge_write_bridge_io_down_a_payload_data[31:0]   ), //o
    .io_down_a_payload_corrupt (bridge_write_bridge_io_down_a_payload_corrupt      ), //o
    .io_down_d_valid           (bridge_downWrite_bus_d_valid                       ), //i
    .io_down_d_ready           (bridge_write_bridge_io_down_d_ready                ), //o
    .io_down_d_payload_opcode  (bridge_downWrite_bus_d_payload_opcode[2:0]         ), //i
    .io_down_d_payload_param   (bridge_downWrite_bus_d_payload_param[2:0]          ), //i
    .io_down_d_payload_source  (bridge_downWrite_bus_d_payload_source[1:0]         ), //i
    .io_down_d_payload_size    (bridge_downWrite_bus_d_payload_size[2:0]           ), //i
    .io_down_d_payload_denied  (bridge_downWrite_bus_d_payload_denied              ), //i
    .clk                       (clk                                                ), //i
    .reset                     (reset                                              )  //i
  );
  Arbiter bridge_down_arbiter_core (
    .io_ups_0_a_valid           (bridge_downRead_to_bridge_down_down_bus_a_valid                 ), //i
    .io_ups_0_a_ready           (bridge_down_arbiter_core_io_ups_0_a_ready                       ), //o
    .io_ups_0_a_payload_opcode  (bridge_downRead_to_bridge_down_down_bus_a_payload_opcode[2:0]   ), //i
    .io_ups_0_a_payload_param   (bridge_downRead_to_bridge_down_down_bus_a_payload_param[2:0]    ), //i
    .io_ups_0_a_payload_source  (bridge_downRead_to_bridge_down_down_bus_a_payload_source[1:0]   ), //i
    .io_ups_0_a_payload_address (bridge_downRead_to_bridge_down_down_bus_a_payload_address[13:0] ), //i
    .io_ups_0_a_payload_size    (bridge_downRead_to_bridge_down_down_bus_a_payload_size[2:0]     ), //i
    .io_ups_0_d_valid           (bridge_down_arbiter_core_io_ups_0_d_valid                       ), //o
    .io_ups_0_d_ready           (bridge_downRead_to_bridge_down_down_bus_d_ready                 ), //i
    .io_ups_0_d_payload_opcode  (bridge_down_arbiter_core_io_ups_0_d_payload_opcode[2:0]         ), //o
    .io_ups_0_d_payload_param   (bridge_down_arbiter_core_io_ups_0_d_payload_param[2:0]          ), //o
    .io_ups_0_d_payload_source  (bridge_down_arbiter_core_io_ups_0_d_payload_source[1:0]         ), //o
    .io_ups_0_d_payload_size    (bridge_down_arbiter_core_io_ups_0_d_payload_size[2:0]           ), //o
    .io_ups_0_d_payload_denied  (bridge_down_arbiter_core_io_ups_0_d_payload_denied              ), //o
    .io_ups_0_d_payload_data    (bridge_down_arbiter_core_io_ups_0_d_payload_data[127:0]         ), //o
    .io_ups_0_d_payload_corrupt (bridge_down_arbiter_core_io_ups_0_d_payload_corrupt             ), //o
    .io_ups_1_a_valid           (bridge_downWrite_to_bridge_down_down_bus_a_valid                ), //i
    .io_ups_1_a_ready           (bridge_down_arbiter_core_io_ups_1_a_ready                       ), //o
    .io_ups_1_a_payload_opcode  (bridge_downWrite_to_bridge_down_down_bus_a_payload_opcode[2:0]  ), //i
    .io_ups_1_a_payload_param   (bridge_downWrite_to_bridge_down_down_bus_a_payload_param[2:0]   ), //i
    .io_ups_1_a_payload_source  (bridge_downWrite_to_bridge_down_down_bus_a_payload_source[1:0]  ), //i
    .io_ups_1_a_payload_address (bridge_downWrite_to_bridge_down_down_bus_a_payload_address[13:0]), //i
    .io_ups_1_a_payload_size    (bridge_downWrite_to_bridge_down_down_bus_a_payload_size[2:0]    ), //i
    .io_ups_1_a_payload_mask    (bridge_downWrite_to_bridge_down_down_bus_a_payload_mask[15:0]   ), //i
    .io_ups_1_a_payload_data    (bridge_downWrite_to_bridge_down_down_bus_a_payload_data[127:0]  ), //i
    .io_ups_1_a_payload_corrupt (bridge_downWrite_to_bridge_down_down_bus_a_payload_corrupt      ), //i
    .io_ups_1_d_valid           (bridge_down_arbiter_core_io_ups_1_d_valid                       ), //o
    .io_ups_1_d_ready           (bridge_downWrite_to_bridge_down_down_bus_d_ready                ), //i
    .io_ups_1_d_payload_opcode  (bridge_down_arbiter_core_io_ups_1_d_payload_opcode[2:0]         ), //o
    .io_ups_1_d_payload_param   (bridge_down_arbiter_core_io_ups_1_d_payload_param[2:0]          ), //o
    .io_ups_1_d_payload_source  (bridge_down_arbiter_core_io_ups_1_d_payload_source[1:0]         ), //o
    .io_ups_1_d_payload_size    (bridge_down_arbiter_core_io_ups_1_d_payload_size[2:0]           ), //o
    .io_ups_1_d_payload_denied  (bridge_down_arbiter_core_io_ups_1_d_payload_denied              ), //o
    .io_down_a_valid            (bridge_down_arbiter_core_io_down_a_valid                        ), //o
    .io_down_a_ready            (bridge_down_bus_a_ready                                         ), //i
    .io_down_a_payload_opcode   (bridge_down_arbiter_core_io_down_a_payload_opcode[2:0]          ), //o
    .io_down_a_payload_param    (bridge_down_arbiter_core_io_down_a_payload_param[2:0]           ), //o
    .io_down_a_payload_source   (bridge_down_arbiter_core_io_down_a_payload_source[2:0]          ), //o
    .io_down_a_payload_address  (bridge_down_arbiter_core_io_down_a_payload_address[13:0]        ), //o
    .io_down_a_payload_size     (bridge_down_arbiter_core_io_down_a_payload_size[2:0]            ), //o
    .io_down_a_payload_mask     (bridge_down_arbiter_core_io_down_a_payload_mask[15:0]           ), //o
    .io_down_a_payload_data     (bridge_down_arbiter_core_io_down_a_payload_data[127:0]          ), //o
    .io_down_a_payload_corrupt  (bridge_down_arbiter_core_io_down_a_payload_corrupt              ), //o
    .io_down_d_valid            (bridge_down_bus_d_valid                                         ), //i
    .io_down_d_ready            (bridge_down_arbiter_core_io_down_d_ready                        ), //o
    .io_down_d_payload_opcode   (bridge_down_bus_d_payload_opcode[2:0]                           ), //i
    .io_down_d_payload_param    (bridge_down_bus_d_payload_param[2:0]                            ), //i
    .io_down_d_payload_source   (bridge_down_bus_d_payload_source[2:0]                           ), //i
    .io_down_d_payload_size     (bridge_down_bus_d_payload_size[2:0]                             ), //i
    .io_down_d_payload_denied   (bridge_down_bus_d_payload_denied                                ), //i
    .io_down_d_payload_data     (bridge_down_bus_d_payload_data[127:0]                           ), //i
    .io_down_d_payload_corrupt  (bridge_down_bus_d_payload_corrupt                               ), //i
    .clk                        (clk                                                             ), //i
    .reset                      (reset                                                           )  //i
  );
  WidthAdapter bridge_downRead_to_bridge_down_widthAdapter (
    .io_up_a_valid             (bridge_downRead_to_bridge_down_up_bus_a_valid                              ), //i
    .io_up_a_ready             (bridge_downRead_to_bridge_down_widthAdapter_io_up_a_ready                  ), //o
    .io_up_a_payload_opcode    (bridge_downRead_to_bridge_down_up_bus_a_payload_opcode[2:0]                ), //i
    .io_up_a_payload_param     (bridge_downRead_to_bridge_down_up_bus_a_payload_param[2:0]                 ), //i
    .io_up_a_payload_source    (bridge_downRead_to_bridge_down_up_bus_a_payload_source[1:0]                ), //i
    .io_up_a_payload_address   (bridge_downRead_to_bridge_down_up_bus_a_payload_address[13:0]              ), //i
    .io_up_a_payload_size      (bridge_downRead_to_bridge_down_up_bus_a_payload_size[2:0]                  ), //i
    .io_up_d_valid             (bridge_downRead_to_bridge_down_widthAdapter_io_up_d_valid                  ), //o
    .io_up_d_ready             (bridge_downRead_to_bridge_down_up_bus_d_ready                              ), //i
    .io_up_d_payload_opcode    (bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_opcode[2:0]    ), //o
    .io_up_d_payload_param     (bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_param[2:0]     ), //o
    .io_up_d_payload_source    (bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_source[1:0]    ), //o
    .io_up_d_payload_size      (bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_size[2:0]      ), //o
    .io_up_d_payload_denied    (bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_denied         ), //o
    .io_up_d_payload_data      (bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_data[31:0]     ), //o
    .io_up_d_payload_corrupt   (bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_corrupt        ), //o
    .io_down_a_valid           (bridge_downRead_to_bridge_down_widthAdapter_io_down_a_valid                ), //o
    .io_down_a_ready           (bridge_downRead_to_bridge_down_down_bus_a_ready                            ), //i
    .io_down_a_payload_opcode  (bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_opcode[2:0]  ), //o
    .io_down_a_payload_param   (bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_param[2:0]   ), //o
    .io_down_a_payload_source  (bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_source[1:0]  ), //o
    .io_down_a_payload_address (bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_address[13:0]), //o
    .io_down_a_payload_size    (bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_size[2:0]    ), //o
    .io_down_d_valid           (bridge_downRead_to_bridge_down_down_bus_d_valid                            ), //i
    .io_down_d_ready           (bridge_downRead_to_bridge_down_widthAdapter_io_down_d_ready                ), //o
    .io_down_d_payload_opcode  (bridge_downRead_to_bridge_down_down_bus_d_payload_opcode[2:0]              ), //i
    .io_down_d_payload_param   (bridge_downRead_to_bridge_down_down_bus_d_payload_param[2:0]               ), //i
    .io_down_d_payload_source  (bridge_downRead_to_bridge_down_down_bus_d_payload_source[1:0]              ), //i
    .io_down_d_payload_size    (bridge_downRead_to_bridge_down_down_bus_d_payload_size[2:0]                ), //i
    .io_down_d_payload_denied  (bridge_downRead_to_bridge_down_down_bus_d_payload_denied                   ), //i
    .io_down_d_payload_data    (bridge_downRead_to_bridge_down_down_bus_d_payload_data[127:0]              ), //i
    .io_down_d_payload_corrupt (bridge_downRead_to_bridge_down_down_bus_d_payload_corrupt                  ), //i
    .clk                       (clk                                                                        ), //i
    .reset                     (reset                                                                      )  //i
  );
  WidthAdapter_1 bridge_downWrite_to_bridge_down_widthAdapter (
    .io_up_a_valid             (bridge_downWrite_to_bridge_down_up_bus_a_valid                              ), //i
    .io_up_a_ready             (bridge_downWrite_to_bridge_down_widthAdapter_io_up_a_ready                  ), //o
    .io_up_a_payload_opcode    (bridge_downWrite_to_bridge_down_up_bus_a_payload_opcode[2:0]                ), //i
    .io_up_a_payload_param     (bridge_downWrite_to_bridge_down_up_bus_a_payload_param[2:0]                 ), //i
    .io_up_a_payload_source    (bridge_downWrite_to_bridge_down_up_bus_a_payload_source[1:0]                ), //i
    .io_up_a_payload_address   (bridge_downWrite_to_bridge_down_up_bus_a_payload_address[13:0]              ), //i
    .io_up_a_payload_size      (bridge_downWrite_to_bridge_down_up_bus_a_payload_size[2:0]                  ), //i
    .io_up_a_payload_mask      (bridge_downWrite_to_bridge_down_up_bus_a_payload_mask[3:0]                  ), //i
    .io_up_a_payload_data      (bridge_downWrite_to_bridge_down_up_bus_a_payload_data[31:0]                 ), //i
    .io_up_a_payload_corrupt   (bridge_downWrite_to_bridge_down_up_bus_a_payload_corrupt                    ), //i
    .io_up_d_valid             (bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_valid                  ), //o
    .io_up_d_ready             (bridge_downWrite_to_bridge_down_up_bus_d_ready                              ), //i
    .io_up_d_payload_opcode    (bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_opcode[2:0]    ), //o
    .io_up_d_payload_param     (bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_param[2:0]     ), //o
    .io_up_d_payload_source    (bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_source[1:0]    ), //o
    .io_up_d_payload_size      (bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_size[2:0]      ), //o
    .io_up_d_payload_denied    (bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_denied         ), //o
    .io_down_a_valid           (bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_valid                ), //o
    .io_down_a_ready           (bridge_downWrite_to_bridge_down_down_bus_a_ready                            ), //i
    .io_down_a_payload_opcode  (bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_opcode[2:0]  ), //o
    .io_down_a_payload_param   (bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_param[2:0]   ), //o
    .io_down_a_payload_source  (bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_source[1:0]  ), //o
    .io_down_a_payload_address (bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_address[13:0]), //o
    .io_down_a_payload_size    (bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_size[2:0]    ), //o
    .io_down_a_payload_mask    (bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_mask[15:0]   ), //o
    .io_down_a_payload_data    (bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_data[127:0]  ), //o
    .io_down_a_payload_corrupt (bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_corrupt      ), //o
    .io_down_d_valid           (bridge_downWrite_to_bridge_down_down_bus_d_valid                            ), //i
    .io_down_d_ready           (bridge_downWrite_to_bridge_down_widthAdapter_io_down_d_ready                ), //o
    .io_down_d_payload_opcode  (bridge_downWrite_to_bridge_down_down_bus_d_payload_opcode[2:0]              ), //i
    .io_down_d_payload_param   (bridge_downWrite_to_bridge_down_down_bus_d_payload_param[2:0]               ), //i
    .io_down_d_payload_source  (bridge_downWrite_to_bridge_down_down_bus_d_payload_source[1:0]              ), //i
    .io_down_d_payload_size    (bridge_downWrite_to_bridge_down_down_bus_d_payload_size[2:0]                ), //i
    .io_down_d_payload_denied  (bridge_downWrite_to_bridge_down_down_bus_d_payload_denied                   ), //i
    .clk                       (clk                                                                         ), //i
    .reset                     (reset                                                                       )  //i
  );
  always @(*) begin
    case(memFiber_thread_logic_pipeline_cmd_SIZE)
      3'b000 : _zz_when_TileLinkAccess_l64 = 1'b0;
      3'b001 : _zz_when_TileLinkAccess_l64 = 1'b0;
      3'b010 : _zz_when_TileLinkAccess_l64 = 1'b0;
      3'b011 : _zz_when_TileLinkAccess_l64 = 1'b0;
      3'b100 : _zz_when_TileLinkAccess_l64 = 1'b0;
      default : _zz_when_TileLinkAccess_l64 = 1'b1;
    endcase
  end

  always @(*) begin
    case(memFiber_thread_logic_io_up_a_payload_size)
      3'b000 : _zz_memFiber_thread_logic_io_up_a_tracker_last = 1'b0;
      3'b001 : _zz_memFiber_thread_logic_io_up_a_tracker_last = 1'b0;
      3'b010 : _zz_memFiber_thread_logic_io_up_a_tracker_last = 1'b0;
      3'b011 : _zz_memFiber_thread_logic_io_up_a_tracker_last = 1'b0;
      3'b100 : _zz_memFiber_thread_logic_io_up_a_tracker_last = 1'b0;
      default : _zz_memFiber_thread_logic_io_up_a_tracker_last = 1'b1;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(bridge_downRead_bus_a_payload_opcode)
      A_PUT_FULL_DATA : bridge_downRead_bus_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : bridge_downRead_bus_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : bridge_downRead_bus_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : bridge_downRead_bus_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : bridge_downRead_bus_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : bridge_downRead_bus_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downRead_bus_d_payload_opcode)
      D_ACCESS_ACK : bridge_downRead_bus_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : bridge_downRead_bus_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : bridge_downRead_bus_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : bridge_downRead_bus_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : bridge_downRead_bus_d_payload_opcode_string = "RELEASE_ACK    ";
      default : bridge_downRead_bus_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downRead_noDecoder_toDown_a_payload_opcode)
      A_PUT_FULL_DATA : bridge_downRead_noDecoder_toDown_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : bridge_downRead_noDecoder_toDown_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : bridge_downRead_noDecoder_toDown_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : bridge_downRead_noDecoder_toDown_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : bridge_downRead_noDecoder_toDown_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : bridge_downRead_noDecoder_toDown_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downRead_noDecoder_toDown_d_payload_opcode)
      D_ACCESS_ACK : bridge_downRead_noDecoder_toDown_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : bridge_downRead_noDecoder_toDown_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : bridge_downRead_noDecoder_toDown_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : bridge_downRead_noDecoder_toDown_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : bridge_downRead_noDecoder_toDown_d_payload_opcode_string = "RELEASE_ACK    ";
      default : bridge_downRead_noDecoder_toDown_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downWrite_bus_a_payload_opcode)
      A_PUT_FULL_DATA : bridge_downWrite_bus_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : bridge_downWrite_bus_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : bridge_downWrite_bus_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : bridge_downWrite_bus_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : bridge_downWrite_bus_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : bridge_downWrite_bus_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downWrite_bus_d_payload_opcode)
      D_ACCESS_ACK : bridge_downWrite_bus_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : bridge_downWrite_bus_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : bridge_downWrite_bus_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : bridge_downWrite_bus_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : bridge_downWrite_bus_d_payload_opcode_string = "RELEASE_ACK    ";
      default : bridge_downWrite_bus_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downWrite_noDecoder_toDown_a_payload_opcode)
      A_PUT_FULL_DATA : bridge_downWrite_noDecoder_toDown_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : bridge_downWrite_noDecoder_toDown_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : bridge_downWrite_noDecoder_toDown_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : bridge_downWrite_noDecoder_toDown_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : bridge_downWrite_noDecoder_toDown_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : bridge_downWrite_noDecoder_toDown_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downWrite_noDecoder_toDown_d_payload_opcode)
      D_ACCESS_ACK : bridge_downWrite_noDecoder_toDown_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : bridge_downWrite_noDecoder_toDown_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : bridge_downWrite_noDecoder_toDown_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : bridge_downWrite_noDecoder_toDown_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : bridge_downWrite_noDecoder_toDown_d_payload_opcode_string = "RELEASE_ACK    ";
      default : bridge_downWrite_noDecoder_toDown_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(bridge_down_bus_a_payload_opcode)
      A_PUT_FULL_DATA : bridge_down_bus_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : bridge_down_bus_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : bridge_down_bus_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : bridge_down_bus_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : bridge_down_bus_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : bridge_down_bus_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(bridge_down_bus_d_payload_opcode)
      D_ACCESS_ACK : bridge_down_bus_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : bridge_down_bus_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : bridge_down_bus_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : bridge_down_bus_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : bridge_down_bus_d_payload_opcode_string = "RELEASE_ACK    ";
      default : bridge_down_bus_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downRead_to_bridge_down_down_bus_a_payload_opcode)
      A_PUT_FULL_DATA : bridge_downRead_to_bridge_down_down_bus_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : bridge_downRead_to_bridge_down_down_bus_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : bridge_downRead_to_bridge_down_down_bus_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : bridge_downRead_to_bridge_down_down_bus_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : bridge_downRead_to_bridge_down_down_bus_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : bridge_downRead_to_bridge_down_down_bus_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downRead_to_bridge_down_down_bus_d_payload_opcode)
      D_ACCESS_ACK : bridge_downRead_to_bridge_down_down_bus_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : bridge_downRead_to_bridge_down_down_bus_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : bridge_downRead_to_bridge_down_down_bus_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : bridge_downRead_to_bridge_down_down_bus_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : bridge_downRead_to_bridge_down_down_bus_d_payload_opcode_string = "RELEASE_ACK    ";
      default : bridge_downRead_to_bridge_down_down_bus_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downWrite_to_bridge_down_down_bus_a_payload_opcode)
      A_PUT_FULL_DATA : bridge_downWrite_to_bridge_down_down_bus_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : bridge_downWrite_to_bridge_down_down_bus_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : bridge_downWrite_to_bridge_down_down_bus_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : bridge_downWrite_to_bridge_down_down_bus_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : bridge_downWrite_to_bridge_down_down_bus_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : bridge_downWrite_to_bridge_down_down_bus_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downWrite_to_bridge_down_down_bus_d_payload_opcode)
      D_ACCESS_ACK : bridge_downWrite_to_bridge_down_down_bus_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : bridge_downWrite_to_bridge_down_down_bus_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : bridge_downWrite_to_bridge_down_down_bus_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : bridge_downWrite_to_bridge_down_down_bus_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : bridge_downWrite_to_bridge_down_down_bus_d_payload_opcode_string = "RELEASE_ACK    ";
      default : bridge_downWrite_to_bridge_down_down_bus_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(bridge_down_noDecoder_toDown_a_payload_opcode)
      A_PUT_FULL_DATA : bridge_down_noDecoder_toDown_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : bridge_down_noDecoder_toDown_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : bridge_down_noDecoder_toDown_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : bridge_down_noDecoder_toDown_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : bridge_down_noDecoder_toDown_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : bridge_down_noDecoder_toDown_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(bridge_down_noDecoder_toDown_d_payload_opcode)
      D_ACCESS_ACK : bridge_down_noDecoder_toDown_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : bridge_down_noDecoder_toDown_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : bridge_down_noDecoder_toDown_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : bridge_down_noDecoder_toDown_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : bridge_down_noDecoder_toDown_d_payload_opcode_string = "RELEASE_ACK    ";
      default : bridge_down_noDecoder_toDown_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(memFiber_up_bus_a_payload_opcode)
      A_PUT_FULL_DATA : memFiber_up_bus_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : memFiber_up_bus_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : memFiber_up_bus_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : memFiber_up_bus_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : memFiber_up_bus_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : memFiber_up_bus_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(memFiber_up_bus_d_payload_opcode)
      D_ACCESS_ACK : memFiber_up_bus_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : memFiber_up_bus_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : memFiber_up_bus_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : memFiber_up_bus_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : memFiber_up_bus_d_payload_opcode_string = "RELEASE_ACK    ";
      default : memFiber_up_bus_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(bridge_down_to_memFiber_up_down_bus_a_payload_opcode)
      A_PUT_FULL_DATA : bridge_down_to_memFiber_up_down_bus_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : bridge_down_to_memFiber_up_down_bus_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : bridge_down_to_memFiber_up_down_bus_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : bridge_down_to_memFiber_up_down_bus_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : bridge_down_to_memFiber_up_down_bus_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : bridge_down_to_memFiber_up_down_bus_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(bridge_down_to_memFiber_up_down_bus_d_payload_opcode)
      D_ACCESS_ACK : bridge_down_to_memFiber_up_down_bus_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : bridge_down_to_memFiber_up_down_bus_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : bridge_down_to_memFiber_up_down_bus_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : bridge_down_to_memFiber_up_down_bus_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : bridge_down_to_memFiber_up_down_bus_d_payload_opcode_string = "RELEASE_ACK    ";
      default : bridge_down_to_memFiber_up_down_bus_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downRead_to_bridge_down_up_bus_a_payload_opcode)
      A_PUT_FULL_DATA : bridge_downRead_to_bridge_down_up_bus_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : bridge_downRead_to_bridge_down_up_bus_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : bridge_downRead_to_bridge_down_up_bus_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : bridge_downRead_to_bridge_down_up_bus_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : bridge_downRead_to_bridge_down_up_bus_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : bridge_downRead_to_bridge_down_up_bus_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downRead_to_bridge_down_up_bus_d_payload_opcode)
      D_ACCESS_ACK : bridge_downRead_to_bridge_down_up_bus_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : bridge_downRead_to_bridge_down_up_bus_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : bridge_downRead_to_bridge_down_up_bus_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : bridge_downRead_to_bridge_down_up_bus_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : bridge_downRead_to_bridge_down_up_bus_d_payload_opcode_string = "RELEASE_ACK    ";
      default : bridge_downRead_to_bridge_down_up_bus_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downWrite_to_bridge_down_up_bus_a_payload_opcode)
      A_PUT_FULL_DATA : bridge_downWrite_to_bridge_down_up_bus_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : bridge_downWrite_to_bridge_down_up_bus_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : bridge_downWrite_to_bridge_down_up_bus_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : bridge_downWrite_to_bridge_down_up_bus_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : bridge_downWrite_to_bridge_down_up_bus_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : bridge_downWrite_to_bridge_down_up_bus_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(bridge_downWrite_to_bridge_down_up_bus_d_payload_opcode)
      D_ACCESS_ACK : bridge_downWrite_to_bridge_down_up_bus_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : bridge_downWrite_to_bridge_down_up_bus_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : bridge_downWrite_to_bridge_down_up_bus_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : bridge_downWrite_to_bridge_down_up_bus_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : bridge_downWrite_to_bridge_down_up_bus_d_payload_opcode_string = "RELEASE_ACK    ";
      default : bridge_downWrite_to_bridge_down_up_bus_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(memFiber_thread_logic_io_up_a_payload_opcode)
      A_PUT_FULL_DATA : memFiber_thread_logic_io_up_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : memFiber_thread_logic_io_up_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : memFiber_thread_logic_io_up_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : memFiber_thread_logic_io_up_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : memFiber_thread_logic_io_up_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : memFiber_thread_logic_io_up_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(memFiber_thread_logic_io_up_d_payload_opcode)
      D_ACCESS_ACK : memFiber_thread_logic_io_up_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : memFiber_thread_logic_io_up_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : memFiber_thread_logic_io_up_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : memFiber_thread_logic_io_up_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : memFiber_thread_logic_io_up_d_payload_opcode_string = "RELEASE_ACK    ";
      default : memFiber_thread_logic_io_up_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(_zz_memFiber_thread_logic_io_up_d_payload_opcode)
      D_ACCESS_ACK : _zz_memFiber_thread_logic_io_up_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : _zz_memFiber_thread_logic_io_up_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : _zz_memFiber_thread_logic_io_up_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : _zz_memFiber_thread_logic_io_up_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : _zz_memFiber_thread_logic_io_up_d_payload_opcode_string = "RELEASE_ACK    ";
      default : _zz_memFiber_thread_logic_io_up_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(bridge_down_to_memFiber_up_up_bus_a_payload_opcode)
      A_PUT_FULL_DATA : bridge_down_to_memFiber_up_up_bus_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : bridge_down_to_memFiber_up_up_bus_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : bridge_down_to_memFiber_up_up_bus_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : bridge_down_to_memFiber_up_up_bus_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : bridge_down_to_memFiber_up_up_bus_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : bridge_down_to_memFiber_up_up_bus_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(bridge_down_to_memFiber_up_up_bus_d_payload_opcode)
      D_ACCESS_ACK : bridge_down_to_memFiber_up_up_bus_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : bridge_down_to_memFiber_up_up_bus_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : bridge_down_to_memFiber_up_up_bus_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : bridge_down_to_memFiber_up_up_bus_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : bridge_down_to_memFiber_up_up_bus_d_payload_opcode_string = "RELEASE_ACK    ";
      default : bridge_down_to_memFiber_up_up_bus_d_payload_opcode_string = "???????????????";
    endcase
  end
  `endif

  assign _zz_memFiber_thread_logic_io_up_d_payload_data_4 = memFiber_thread_logic_io_up_a_payload_data;
  assign AXI_ARREADY = bridge_read_bridge_io_up_ar_ready;
  assign AXI_RVALID = bridge_read_bridge_io_up_r_valid;
  assign AXI_RDATA = bridge_read_bridge_io_up_r_payload_data;
  assign AXI_RLAST = bridge_read_bridge_io_up_r_payload_last;
  assign AXI_RID = bridge_read_bridge_io_up_r_payload_id;
  assign AXI_RRESP = bridge_read_bridge_io_up_r_payload_resp;
  assign AXI_AWREADY = bridge_write_bridge_io_up_aw_ready;
  assign AXI_WREADY = bridge_write_bridge_io_up_w_ready;
  assign AXI_BVALID = bridge_write_bridge_io_up_b_valid;
  assign AXI_BID = bridge_write_bridge_io_up_b_payload_id;
  assign AXI_BRESP = bridge_write_bridge_io_up_b_payload_resp;
  assign bridge_downRead_noDecoder_toDown_a_valid = bridge_downRead_bus_a_valid;
  assign bridge_downRead_bus_a_ready = bridge_downRead_noDecoder_toDown_a_ready;
  assign bridge_downRead_noDecoder_toDown_a_payload_opcode = bridge_downRead_bus_a_payload_opcode;
  assign bridge_downRead_noDecoder_toDown_a_payload_param = bridge_downRead_bus_a_payload_param;
  assign bridge_downRead_noDecoder_toDown_a_payload_source = bridge_downRead_bus_a_payload_source;
  assign bridge_downRead_noDecoder_toDown_a_payload_address = bridge_downRead_bus_a_payload_address;
  assign bridge_downRead_noDecoder_toDown_a_payload_size = bridge_downRead_bus_a_payload_size;
  assign bridge_downRead_bus_d_valid = bridge_downRead_noDecoder_toDown_d_valid;
  assign bridge_downRead_noDecoder_toDown_d_ready = bridge_downRead_bus_d_ready;
  assign bridge_downRead_bus_d_payload_opcode = bridge_downRead_noDecoder_toDown_d_payload_opcode;
  assign bridge_downRead_bus_d_payload_param = bridge_downRead_noDecoder_toDown_d_payload_param;
  assign bridge_downRead_bus_d_payload_source = bridge_downRead_noDecoder_toDown_d_payload_source;
  assign bridge_downRead_bus_d_payload_size = bridge_downRead_noDecoder_toDown_d_payload_size;
  assign bridge_downRead_bus_d_payload_denied = bridge_downRead_noDecoder_toDown_d_payload_denied;
  assign bridge_downRead_bus_d_payload_data = bridge_downRead_noDecoder_toDown_d_payload_data;
  assign bridge_downRead_bus_d_payload_corrupt = bridge_downRead_noDecoder_toDown_d_payload_corrupt;
  assign bridge_downWrite_noDecoder_toDown_a_valid = bridge_downWrite_bus_a_valid;
  assign bridge_downWrite_bus_a_ready = bridge_downWrite_noDecoder_toDown_a_ready;
  assign bridge_downWrite_noDecoder_toDown_a_payload_opcode = bridge_downWrite_bus_a_payload_opcode;
  assign bridge_downWrite_noDecoder_toDown_a_payload_param = bridge_downWrite_bus_a_payload_param;
  assign bridge_downWrite_noDecoder_toDown_a_payload_source = bridge_downWrite_bus_a_payload_source;
  assign bridge_downWrite_noDecoder_toDown_a_payload_address = bridge_downWrite_bus_a_payload_address;
  assign bridge_downWrite_noDecoder_toDown_a_payload_size = bridge_downWrite_bus_a_payload_size;
  assign bridge_downWrite_noDecoder_toDown_a_payload_mask = bridge_downWrite_bus_a_payload_mask;
  assign bridge_downWrite_noDecoder_toDown_a_payload_data = bridge_downWrite_bus_a_payload_data;
  assign bridge_downWrite_noDecoder_toDown_a_payload_corrupt = bridge_downWrite_bus_a_payload_corrupt;
  assign bridge_downWrite_bus_d_valid = bridge_downWrite_noDecoder_toDown_d_valid;
  assign bridge_downWrite_noDecoder_toDown_d_ready = bridge_downWrite_bus_d_ready;
  assign bridge_downWrite_bus_d_payload_opcode = bridge_downWrite_noDecoder_toDown_d_payload_opcode;
  assign bridge_downWrite_bus_d_payload_param = bridge_downWrite_noDecoder_toDown_d_payload_param;
  assign bridge_downWrite_bus_d_payload_source = bridge_downWrite_noDecoder_toDown_d_payload_source;
  assign bridge_downWrite_bus_d_payload_size = bridge_downWrite_noDecoder_toDown_d_payload_size;
  assign bridge_downWrite_bus_d_payload_denied = bridge_downWrite_noDecoder_toDown_d_payload_denied;
  assign bridge_downRead_bus_a_valid = bridge_read_bridge_io_down_a_valid;
  assign bridge_downRead_bus_a_payload_opcode = bridge_read_bridge_io_down_a_payload_opcode;
  assign bridge_downRead_bus_a_payload_param = bridge_read_bridge_io_down_a_payload_param;
  assign bridge_downRead_bus_a_payload_source = bridge_read_bridge_io_down_a_payload_source;
  assign bridge_downRead_bus_a_payload_address = bridge_read_bridge_io_down_a_payload_address;
  assign bridge_downRead_bus_a_payload_size = bridge_read_bridge_io_down_a_payload_size;
  assign bridge_downRead_bus_d_ready = bridge_read_bridge_io_down_d_ready;
  assign bridge_downWrite_bus_a_valid = bridge_write_bridge_io_down_a_valid;
  assign bridge_downWrite_bus_a_payload_opcode = bridge_write_bridge_io_down_a_payload_opcode;
  assign bridge_downWrite_bus_a_payload_param = bridge_write_bridge_io_down_a_payload_param;
  assign bridge_downWrite_bus_a_payload_source = bridge_write_bridge_io_down_a_payload_source;
  assign bridge_downWrite_bus_a_payload_address = bridge_write_bridge_io_down_a_payload_address;
  assign bridge_downWrite_bus_a_payload_size = bridge_write_bridge_io_down_a_payload_size;
  assign bridge_downWrite_bus_a_payload_mask = bridge_write_bridge_io_down_a_payload_mask;
  assign bridge_downWrite_bus_a_payload_data = bridge_write_bridge_io_down_a_payload_data;
  assign bridge_downWrite_bus_a_payload_corrupt = bridge_write_bridge_io_down_a_payload_corrupt;
  assign bridge_downWrite_bus_d_ready = bridge_write_bridge_io_down_d_ready;
  assign bridge_downRead_to_bridge_down_down_bus_a_ready = bridge_down_arbiter_core_io_ups_0_a_ready;
  assign bridge_downRead_to_bridge_down_down_bus_d_valid = bridge_down_arbiter_core_io_ups_0_d_valid;
  assign bridge_downRead_to_bridge_down_down_bus_d_payload_opcode = bridge_down_arbiter_core_io_ups_0_d_payload_opcode;
  assign bridge_downRead_to_bridge_down_down_bus_d_payload_param = bridge_down_arbiter_core_io_ups_0_d_payload_param;
  assign bridge_downRead_to_bridge_down_down_bus_d_payload_source = bridge_down_arbiter_core_io_ups_0_d_payload_source;
  assign bridge_downRead_to_bridge_down_down_bus_d_payload_size = bridge_down_arbiter_core_io_ups_0_d_payload_size;
  assign bridge_downRead_to_bridge_down_down_bus_d_payload_denied = bridge_down_arbiter_core_io_ups_0_d_payload_denied;
  assign bridge_downRead_to_bridge_down_down_bus_d_payload_data = bridge_down_arbiter_core_io_ups_0_d_payload_data;
  assign bridge_downRead_to_bridge_down_down_bus_d_payload_corrupt = bridge_down_arbiter_core_io_ups_0_d_payload_corrupt;
  assign bridge_downWrite_to_bridge_down_down_bus_a_ready = bridge_down_arbiter_core_io_ups_1_a_ready;
  assign bridge_downWrite_to_bridge_down_down_bus_d_valid = bridge_down_arbiter_core_io_ups_1_d_valid;
  assign bridge_downWrite_to_bridge_down_down_bus_d_payload_opcode = bridge_down_arbiter_core_io_ups_1_d_payload_opcode;
  assign bridge_downWrite_to_bridge_down_down_bus_d_payload_param = bridge_down_arbiter_core_io_ups_1_d_payload_param;
  assign bridge_downWrite_to_bridge_down_down_bus_d_payload_source = bridge_down_arbiter_core_io_ups_1_d_payload_source;
  assign bridge_downWrite_to_bridge_down_down_bus_d_payload_size = bridge_down_arbiter_core_io_ups_1_d_payload_size;
  assign bridge_downWrite_to_bridge_down_down_bus_d_payload_denied = bridge_down_arbiter_core_io_ups_1_d_payload_denied;
  assign bridge_down_bus_a_valid = bridge_down_arbiter_core_io_down_a_valid;
  assign bridge_down_bus_a_payload_opcode = bridge_down_arbiter_core_io_down_a_payload_opcode;
  assign bridge_down_bus_a_payload_param = bridge_down_arbiter_core_io_down_a_payload_param;
  assign bridge_down_bus_a_payload_source = bridge_down_arbiter_core_io_down_a_payload_source;
  assign bridge_down_bus_a_payload_address = bridge_down_arbiter_core_io_down_a_payload_address;
  assign bridge_down_bus_a_payload_size = bridge_down_arbiter_core_io_down_a_payload_size;
  assign bridge_down_bus_a_payload_mask = bridge_down_arbiter_core_io_down_a_payload_mask;
  assign bridge_down_bus_a_payload_data = bridge_down_arbiter_core_io_down_a_payload_data;
  assign bridge_down_bus_a_payload_corrupt = bridge_down_arbiter_core_io_down_a_payload_corrupt;
  assign bridge_down_bus_d_ready = bridge_down_arbiter_core_io_down_d_ready;
  assign bridge_down_noDecoder_toDown_a_valid = bridge_down_bus_a_valid;
  assign bridge_down_bus_a_ready = bridge_down_noDecoder_toDown_a_ready;
  assign bridge_down_noDecoder_toDown_a_payload_opcode = bridge_down_bus_a_payload_opcode;
  assign bridge_down_noDecoder_toDown_a_payload_param = bridge_down_bus_a_payload_param;
  assign bridge_down_noDecoder_toDown_a_payload_source = bridge_down_bus_a_payload_source;
  assign bridge_down_noDecoder_toDown_a_payload_address = bridge_down_bus_a_payload_address;
  assign bridge_down_noDecoder_toDown_a_payload_size = bridge_down_bus_a_payload_size;
  assign bridge_down_noDecoder_toDown_a_payload_mask = bridge_down_bus_a_payload_mask;
  assign bridge_down_noDecoder_toDown_a_payload_data = bridge_down_bus_a_payload_data;
  assign bridge_down_noDecoder_toDown_a_payload_corrupt = bridge_down_bus_a_payload_corrupt;
  assign bridge_down_bus_d_valid = bridge_down_noDecoder_toDown_d_valid;
  assign bridge_down_noDecoder_toDown_d_ready = bridge_down_bus_d_ready;
  assign bridge_down_bus_d_payload_opcode = bridge_down_noDecoder_toDown_d_payload_opcode;
  assign bridge_down_bus_d_payload_param = bridge_down_noDecoder_toDown_d_payload_param;
  assign bridge_down_bus_d_payload_source = bridge_down_noDecoder_toDown_d_payload_source;
  assign bridge_down_bus_d_payload_size = bridge_down_noDecoder_toDown_d_payload_size;
  assign bridge_down_bus_d_payload_denied = bridge_down_noDecoder_toDown_d_payload_denied;
  assign bridge_down_bus_d_payload_data = bridge_down_noDecoder_toDown_d_payload_data;
  assign bridge_down_bus_d_payload_corrupt = bridge_down_noDecoder_toDown_d_payload_corrupt;
  assign memFiber_up_bus_a_valid = bridge_down_to_memFiber_up_down_bus_a_valid;
  assign bridge_down_to_memFiber_up_down_bus_a_ready = memFiber_up_bus_a_ready;
  assign memFiber_up_bus_a_payload_opcode = bridge_down_to_memFiber_up_down_bus_a_payload_opcode;
  assign memFiber_up_bus_a_payload_param = bridge_down_to_memFiber_up_down_bus_a_payload_param;
  assign memFiber_up_bus_a_payload_source = bridge_down_to_memFiber_up_down_bus_a_payload_source;
  assign memFiber_up_bus_a_payload_address = bridge_down_to_memFiber_up_down_bus_a_payload_address;
  assign memFiber_up_bus_a_payload_size = bridge_down_to_memFiber_up_down_bus_a_payload_size;
  assign memFiber_up_bus_a_payload_mask = bridge_down_to_memFiber_up_down_bus_a_payload_mask;
  assign memFiber_up_bus_a_payload_data = bridge_down_to_memFiber_up_down_bus_a_payload_data;
  assign memFiber_up_bus_a_payload_corrupt = bridge_down_to_memFiber_up_down_bus_a_payload_corrupt;
  assign bridge_down_to_memFiber_up_down_bus_d_valid = memFiber_up_bus_d_valid;
  assign memFiber_up_bus_d_ready = bridge_down_to_memFiber_up_down_bus_d_ready;
  assign bridge_down_to_memFiber_up_down_bus_d_payload_opcode = memFiber_up_bus_d_payload_opcode;
  assign bridge_down_to_memFiber_up_down_bus_d_payload_param = memFiber_up_bus_d_payload_param;
  assign bridge_down_to_memFiber_up_down_bus_d_payload_source = memFiber_up_bus_d_payload_source;
  assign bridge_down_to_memFiber_up_down_bus_d_payload_size = memFiber_up_bus_d_payload_size;
  assign bridge_down_to_memFiber_up_down_bus_d_payload_denied = memFiber_up_bus_d_payload_denied;
  assign bridge_down_to_memFiber_up_down_bus_d_payload_data = memFiber_up_bus_d_payload_data;
  assign bridge_down_to_memFiber_up_down_bus_d_payload_corrupt = memFiber_up_bus_d_payload_corrupt;
  assign bridge_downRead_to_bridge_down_up_bus_a_valid = bridge_downRead_noDecoder_toDown_a_valid;
  assign bridge_downRead_noDecoder_toDown_a_ready = bridge_downRead_to_bridge_down_up_bus_a_ready;
  assign bridge_downRead_to_bridge_down_up_bus_a_payload_opcode = bridge_downRead_noDecoder_toDown_a_payload_opcode;
  assign bridge_downRead_to_bridge_down_up_bus_a_payload_param = bridge_downRead_noDecoder_toDown_a_payload_param;
  assign bridge_downRead_to_bridge_down_up_bus_a_payload_source = bridge_downRead_noDecoder_toDown_a_payload_source;
  assign bridge_downRead_noDecoder_toDown_d_valid = bridge_downRead_to_bridge_down_up_bus_d_valid;
  assign bridge_downRead_to_bridge_down_up_bus_d_ready = bridge_downRead_noDecoder_toDown_d_ready;
  assign bridge_downRead_noDecoder_toDown_d_payload_opcode = bridge_downRead_to_bridge_down_up_bus_d_payload_opcode;
  assign bridge_downRead_noDecoder_toDown_d_payload_param = bridge_downRead_to_bridge_down_up_bus_d_payload_param;
  assign bridge_downRead_noDecoder_toDown_d_payload_source = bridge_downRead_to_bridge_down_up_bus_d_payload_source;
  assign bridge_downRead_noDecoder_toDown_d_payload_denied = bridge_downRead_to_bridge_down_up_bus_d_payload_denied;
  assign bridge_downRead_noDecoder_toDown_d_payload_data = bridge_downRead_to_bridge_down_up_bus_d_payload_data;
  assign bridge_downRead_noDecoder_toDown_d_payload_corrupt = bridge_downRead_to_bridge_down_up_bus_d_payload_corrupt;
  assign bridge_downRead_to_bridge_down_up_bus_a_payload_size = bridge_downRead_noDecoder_toDown_a_payload_size;
  assign bridge_downRead_noDecoder_toDown_d_payload_size = bridge_downRead_to_bridge_down_up_bus_d_payload_size;
  assign bridge_downRead_to_bridge_down_up_bus_a_payload_address = bridge_downRead_noDecoder_toDown_a_payload_address[13:0];
  assign bridge_downWrite_to_bridge_down_up_bus_a_valid = bridge_downWrite_noDecoder_toDown_a_valid;
  assign bridge_downWrite_noDecoder_toDown_a_ready = bridge_downWrite_to_bridge_down_up_bus_a_ready;
  assign bridge_downWrite_to_bridge_down_up_bus_a_payload_opcode = bridge_downWrite_noDecoder_toDown_a_payload_opcode;
  assign bridge_downWrite_to_bridge_down_up_bus_a_payload_param = bridge_downWrite_noDecoder_toDown_a_payload_param;
  assign bridge_downWrite_to_bridge_down_up_bus_a_payload_source = bridge_downWrite_noDecoder_toDown_a_payload_source;
  assign bridge_downWrite_to_bridge_down_up_bus_a_payload_mask = bridge_downWrite_noDecoder_toDown_a_payload_mask;
  assign bridge_downWrite_to_bridge_down_up_bus_a_payload_data = bridge_downWrite_noDecoder_toDown_a_payload_data;
  assign bridge_downWrite_to_bridge_down_up_bus_a_payload_corrupt = bridge_downWrite_noDecoder_toDown_a_payload_corrupt;
  assign bridge_downWrite_noDecoder_toDown_d_valid = bridge_downWrite_to_bridge_down_up_bus_d_valid;
  assign bridge_downWrite_to_bridge_down_up_bus_d_ready = bridge_downWrite_noDecoder_toDown_d_ready;
  assign bridge_downWrite_noDecoder_toDown_d_payload_opcode = bridge_downWrite_to_bridge_down_up_bus_d_payload_opcode;
  assign bridge_downWrite_noDecoder_toDown_d_payload_param = bridge_downWrite_to_bridge_down_up_bus_d_payload_param;
  assign bridge_downWrite_noDecoder_toDown_d_payload_source = bridge_downWrite_to_bridge_down_up_bus_d_payload_source;
  assign bridge_downWrite_noDecoder_toDown_d_payload_denied = bridge_downWrite_to_bridge_down_up_bus_d_payload_denied;
  assign bridge_downWrite_to_bridge_down_up_bus_a_payload_size = bridge_downWrite_noDecoder_toDown_a_payload_size;
  assign bridge_downWrite_noDecoder_toDown_d_payload_size = bridge_downWrite_to_bridge_down_up_bus_d_payload_size;
  assign bridge_downWrite_to_bridge_down_up_bus_a_payload_address = bridge_downWrite_noDecoder_toDown_a_payload_address[13:0];
  always @(*) begin
    memFiber_thread_logic_pipeline_cmd_IS_GET = (|(memFiber_thread_logic_io_up_a_payload_opcode == A_GET));
    if(memFiber_thread_logic_pipeline_cmd_fsm_busy) begin
      memFiber_thread_logic_pipeline_cmd_IS_GET = memFiber_thread_logic_pipeline_cmd_fsm_isGet;
    end
  end

  always @(*) begin
    memFiber_thread_logic_pipeline_cmd_SIZE = memFiber_thread_logic_io_up_a_payload_size;
    if(memFiber_thread_logic_pipeline_cmd_fsm_busy) begin
      memFiber_thread_logic_pipeline_cmd_SIZE = memFiber_thread_logic_pipeline_cmd_fsm_size;
    end
  end

  always @(*) begin
    memFiber_thread_logic_pipeline_cmd_SOURCE = memFiber_thread_logic_io_up_a_payload_source;
    if(memFiber_thread_logic_pipeline_cmd_fsm_busy) begin
      memFiber_thread_logic_pipeline_cmd_SOURCE = memFiber_thread_logic_pipeline_cmd_fsm_source;
    end
  end

  always @(*) begin
    memFiber_thread_logic_pipeline_cmd_LAST = 1'b1;
    if(when_TileLinkAccess_l64) begin
      memFiber_thread_logic_pipeline_cmd_LAST = 1'b0;
    end
  end

  always @(*) begin
    memFiber_thread_logic_pipeline_cmd_valid = memFiber_thread_logic_io_up_a_valid;
    if(when_TileLinkAccess_l52) begin
      memFiber_thread_logic_pipeline_cmd_valid = 1'b1;
    end
  end

  always @(*) begin
    memFiber_thread_logic_io_up_a_ready = memFiber_thread_logic_pipeline_cmd_ready;
    if(when_TileLinkAccess_l52) begin
      memFiber_thread_logic_io_up_a_ready = 1'b0;
    end
  end

  assign memFiber_thread_logic_pipeline_cmd_addressShifted = (memFiber_thread_logic_io_up_a_payload_address >>> 3'd4);
  assign memFiber_thread_logic_pipeline_cmd_isFireing = (memFiber_thread_logic_pipeline_cmd_valid && memFiber_thread_logic_pipeline_cmd_ready);
  assign _zz_memFiber_thread_logic_io_up_d_payload_data_1 = memFiber_thread_logic_pipeline_cmd_isFireing;
  assign _zz_memFiber_thread_logic_io_up_d_payload_data_2 = (! memFiber_thread_logic_pipeline_cmd_IS_GET);
  assign _zz_memFiber_thread_logic_io_up_d_payload_data_3 = memFiber_thread_logic_io_up_a_payload_mask;
  assign memFiber_thread_logic_pipeline_cmd_fsm_busy = (memFiber_thread_logic_pipeline_cmd_fsm_counter != 1'b0);
  assign when_TileLinkAccess_l52 = (memFiber_thread_logic_pipeline_cmd_fsm_busy && memFiber_thread_logic_pipeline_cmd_fsm_isGet);
  assign memFiber_thread_logic_io_up_a_fire = (memFiber_thread_logic_io_up_a_valid && memFiber_thread_logic_io_up_a_ready);
  assign when_TileLinkAccess_l57 = (memFiber_thread_logic_io_up_a_fire && (! memFiber_thread_logic_pipeline_cmd_fsm_busy));
  assign when_TileLinkAccess_l64 = (memFiber_thread_logic_pipeline_cmd_fsm_counter != _zz_when_TileLinkAccess_l64);
  assign _zz_memFiber_thread_logic_io_up_d_payload_data = ((memFiber_thread_logic_pipeline_cmd_fsm_busy ? memFiber_thread_logic_pipeline_cmd_fsm_address : memFiber_thread_logic_pipeline_cmd_addressShifted) | _zz__zz_memFiber_thread_logic_io_up_d_payload_data);
  assign memFiber_thread_logic_pipeline_rsp_takeIt = (memFiber_thread_logic_pipeline_rsp_cmd_LAST || memFiber_thread_logic_pipeline_rsp_cmd_IS_GET);
  assign memFiber_thread_logic_pipeline_rsp_haltRequest_TileLinkAccess_l83 = ((! memFiber_thread_logic_io_up_d_ready) && memFiber_thread_logic_pipeline_rsp_takeIt);
  assign memFiber_thread_logic_io_up_d_valid = (memFiber_thread_logic_pipeline_rsp_valid && memFiber_thread_logic_pipeline_rsp_takeIt);
  assign _zz_memFiber_thread_logic_io_up_d_payload_opcode = (memFiber_thread_logic_pipeline_rsp_cmd_IS_GET ? D_ACCESS_ACK_DATA : D_ACCESS_ACK);
  assign memFiber_thread_logic_io_up_d_payload_opcode = _zz_memFiber_thread_logic_io_up_d_payload_opcode;
  assign memFiber_thread_logic_io_up_d_payload_param = 3'b000;
  assign memFiber_thread_logic_io_up_d_payload_source = memFiber_thread_logic_pipeline_rsp_cmd_SOURCE;
  assign memFiber_thread_logic_io_up_d_payload_size = memFiber_thread_logic_pipeline_rsp_cmd_SIZE;
  assign memFiber_thread_logic_io_up_d_payload_denied = 1'b0;
  assign memFiber_thread_logic_io_up_d_payload_corrupt = 1'b0;
  assign memFiber_thread_logic_io_up_d_payload_data = mem_spinal_port0;
  assign memFiber_thread_logic_pipeline_cmd_ready = memFiber_thread_logic_pipeline_cmd_ready_output;
  always @(*) begin
    memFiber_thread_logic_pipeline_rsp_ready = 1'b1;
    if(when_Pipeline_l278) begin
      memFiber_thread_logic_pipeline_rsp_ready = 1'b0;
    end
  end

  assign when_Pipeline_l278 = (|memFiber_thread_logic_pipeline_rsp_haltRequest_TileLinkAccess_l83);
  always @(*) begin
    memFiber_thread_logic_pipeline_cmd_ready_output = memFiber_thread_logic_pipeline_rsp_ready;
    if(when_Connection_l74) begin
      memFiber_thread_logic_pipeline_cmd_ready_output = 1'b1;
    end
  end

  assign when_Connection_l74 = (! memFiber_thread_logic_pipeline_rsp_valid);
  assign memFiber_thread_logic_io_up_a_tracker_last = ((! ((1'b0 || (A_PUT_FULL_DATA == memFiber_thread_logic_io_up_a_payload_opcode)) || (A_PUT_PARTIAL_DATA == memFiber_thread_logic_io_up_a_payload_opcode))) || (memFiber_thread_logic_io_up_a_tracker_beat == _zz_memFiber_thread_logic_io_up_a_tracker_last));
  assign memFiber_thread_logic_ordering_valid = (memFiber_thread_logic_io_up_a_fire && memFiber_thread_logic_io_up_a_tracker_last);
  assign memFiber_thread_logic_ordering_payload_bytes = _zz_memFiber_thread_logic_ordering_payload_bytes[5:0];
  assign memFiber_thread_logic_io_up_a_valid = memFiber_up_bus_a_valid;
  assign memFiber_up_bus_a_ready = memFiber_thread_logic_io_up_a_ready;
  assign memFiber_thread_logic_io_up_a_payload_opcode = memFiber_up_bus_a_payload_opcode;
  assign memFiber_thread_logic_io_up_a_payload_param = memFiber_up_bus_a_payload_param;
  assign memFiber_thread_logic_io_up_a_payload_source = memFiber_up_bus_a_payload_source;
  assign memFiber_thread_logic_io_up_a_payload_address = memFiber_up_bus_a_payload_address;
  assign memFiber_thread_logic_io_up_a_payload_size = memFiber_up_bus_a_payload_size;
  assign memFiber_thread_logic_io_up_a_payload_mask = memFiber_up_bus_a_payload_mask;
  assign memFiber_thread_logic_io_up_a_payload_data = memFiber_up_bus_a_payload_data;
  assign memFiber_thread_logic_io_up_a_payload_corrupt = memFiber_up_bus_a_payload_corrupt;
  assign memFiber_up_bus_d_valid = memFiber_thread_logic_io_up_d_valid;
  assign memFiber_thread_logic_io_up_d_ready = memFiber_up_bus_d_ready;
  assign memFiber_up_bus_d_payload_opcode = memFiber_thread_logic_io_up_d_payload_opcode;
  assign memFiber_up_bus_d_payload_param = memFiber_thread_logic_io_up_d_payload_param;
  assign memFiber_up_bus_d_payload_source = memFiber_thread_logic_io_up_d_payload_source;
  assign memFiber_up_bus_d_payload_size = memFiber_thread_logic_io_up_d_payload_size;
  assign memFiber_up_bus_d_payload_denied = memFiber_thread_logic_io_up_d_payload_denied;
  assign memFiber_up_bus_d_payload_data = memFiber_thread_logic_io_up_d_payload_data;
  assign memFiber_up_bus_d_payload_corrupt = memFiber_thread_logic_io_up_d_payload_corrupt;
  assign bridge_downRead_to_bridge_down_up_bus_a_ready = bridge_downRead_to_bridge_down_widthAdapter_io_up_a_ready;
  assign bridge_downRead_to_bridge_down_up_bus_d_valid = bridge_downRead_to_bridge_down_widthAdapter_io_up_d_valid;
  assign bridge_downRead_to_bridge_down_up_bus_d_payload_opcode = bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_opcode;
  assign bridge_downRead_to_bridge_down_up_bus_d_payload_param = bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_param;
  assign bridge_downRead_to_bridge_down_up_bus_d_payload_source = bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_source;
  assign bridge_downRead_to_bridge_down_up_bus_d_payload_size = bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_size;
  assign bridge_downRead_to_bridge_down_up_bus_d_payload_denied = bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_denied;
  assign bridge_downRead_to_bridge_down_up_bus_d_payload_data = bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_data;
  assign bridge_downRead_to_bridge_down_up_bus_d_payload_corrupt = bridge_downRead_to_bridge_down_widthAdapter_io_up_d_payload_corrupt;
  assign bridge_downRead_to_bridge_down_down_bus_a_valid = bridge_downRead_to_bridge_down_widthAdapter_io_down_a_valid;
  assign bridge_downRead_to_bridge_down_down_bus_a_payload_opcode = bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_opcode;
  assign bridge_downRead_to_bridge_down_down_bus_a_payload_param = bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_param;
  assign bridge_downRead_to_bridge_down_down_bus_a_payload_source = bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_source;
  assign bridge_downRead_to_bridge_down_down_bus_a_payload_address = bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_address;
  assign bridge_downRead_to_bridge_down_down_bus_a_payload_size = bridge_downRead_to_bridge_down_widthAdapter_io_down_a_payload_size;
  assign bridge_downRead_to_bridge_down_down_bus_d_ready = bridge_downRead_to_bridge_down_widthAdapter_io_down_d_ready;
  assign bridge_downWrite_to_bridge_down_up_bus_a_ready = bridge_downWrite_to_bridge_down_widthAdapter_io_up_a_ready;
  assign bridge_downWrite_to_bridge_down_up_bus_d_valid = bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_valid;
  assign bridge_downWrite_to_bridge_down_up_bus_d_payload_opcode = bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_opcode;
  assign bridge_downWrite_to_bridge_down_up_bus_d_payload_param = bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_param;
  assign bridge_downWrite_to_bridge_down_up_bus_d_payload_source = bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_source;
  assign bridge_downWrite_to_bridge_down_up_bus_d_payload_size = bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_size;
  assign bridge_downWrite_to_bridge_down_up_bus_d_payload_denied = bridge_downWrite_to_bridge_down_widthAdapter_io_up_d_payload_denied;
  assign bridge_downWrite_to_bridge_down_down_bus_a_valid = bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_valid;
  assign bridge_downWrite_to_bridge_down_down_bus_a_payload_opcode = bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_opcode;
  assign bridge_downWrite_to_bridge_down_down_bus_a_payload_param = bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_param;
  assign bridge_downWrite_to_bridge_down_down_bus_a_payload_source = bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_source;
  assign bridge_downWrite_to_bridge_down_down_bus_a_payload_address = bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_address;
  assign bridge_downWrite_to_bridge_down_down_bus_a_payload_size = bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_size;
  assign bridge_downWrite_to_bridge_down_down_bus_a_payload_mask = bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_mask;
  assign bridge_downWrite_to_bridge_down_down_bus_a_payload_data = bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_data;
  assign bridge_downWrite_to_bridge_down_down_bus_a_payload_corrupt = bridge_downWrite_to_bridge_down_widthAdapter_io_down_a_payload_corrupt;
  assign bridge_downWrite_to_bridge_down_down_bus_d_ready = bridge_downWrite_to_bridge_down_widthAdapter_io_down_d_ready;
  assign bridge_down_to_memFiber_up_up_bus_a_valid = bridge_down_noDecoder_toDown_a_valid;
  assign bridge_down_noDecoder_toDown_a_ready = bridge_down_to_memFiber_up_up_bus_a_ready;
  assign bridge_down_to_memFiber_up_up_bus_a_payload_opcode = bridge_down_noDecoder_toDown_a_payload_opcode;
  assign bridge_down_to_memFiber_up_up_bus_a_payload_param = bridge_down_noDecoder_toDown_a_payload_param;
  assign bridge_down_to_memFiber_up_up_bus_a_payload_source = bridge_down_noDecoder_toDown_a_payload_source;
  assign bridge_down_to_memFiber_up_up_bus_a_payload_mask = bridge_down_noDecoder_toDown_a_payload_mask;
  assign bridge_down_to_memFiber_up_up_bus_a_payload_data = bridge_down_noDecoder_toDown_a_payload_data;
  assign bridge_down_to_memFiber_up_up_bus_a_payload_corrupt = bridge_down_noDecoder_toDown_a_payload_corrupt;
  assign bridge_down_noDecoder_toDown_d_valid = bridge_down_to_memFiber_up_up_bus_d_valid;
  assign bridge_down_to_memFiber_up_up_bus_d_ready = bridge_down_noDecoder_toDown_d_ready;
  assign bridge_down_noDecoder_toDown_d_payload_opcode = bridge_down_to_memFiber_up_up_bus_d_payload_opcode;
  assign bridge_down_noDecoder_toDown_d_payload_param = bridge_down_to_memFiber_up_up_bus_d_payload_param;
  assign bridge_down_noDecoder_toDown_d_payload_source = bridge_down_to_memFiber_up_up_bus_d_payload_source;
  assign bridge_down_noDecoder_toDown_d_payload_denied = bridge_down_to_memFiber_up_up_bus_d_payload_denied;
  assign bridge_down_noDecoder_toDown_d_payload_data = bridge_down_to_memFiber_up_up_bus_d_payload_data;
  assign bridge_down_noDecoder_toDown_d_payload_corrupt = bridge_down_to_memFiber_up_up_bus_d_payload_corrupt;
  assign bridge_down_to_memFiber_up_up_bus_a_payload_size = bridge_down_noDecoder_toDown_a_payload_size;
  assign bridge_down_noDecoder_toDown_d_payload_size = bridge_down_to_memFiber_up_up_bus_d_payload_size;
  assign bridge_down_to_memFiber_up_up_bus_a_payload_address = (bridge_down_noDecoder_toDown_a_payload_address - 14'h0);
  assign bridge_down_to_memFiber_up_down_bus_a_valid = bridge_down_to_memFiber_up_up_bus_a_valid;
  assign bridge_down_to_memFiber_up_up_bus_a_ready = bridge_down_to_memFiber_up_down_bus_a_ready;
  assign bridge_down_to_memFiber_up_down_bus_a_payload_opcode = bridge_down_to_memFiber_up_up_bus_a_payload_opcode;
  assign bridge_down_to_memFiber_up_down_bus_a_payload_param = bridge_down_to_memFiber_up_up_bus_a_payload_param;
  assign bridge_down_to_memFiber_up_down_bus_a_payload_source = bridge_down_to_memFiber_up_up_bus_a_payload_source;
  assign bridge_down_to_memFiber_up_down_bus_a_payload_address = bridge_down_to_memFiber_up_up_bus_a_payload_address;
  assign bridge_down_to_memFiber_up_down_bus_a_payload_size = bridge_down_to_memFiber_up_up_bus_a_payload_size;
  assign bridge_down_to_memFiber_up_down_bus_a_payload_mask = bridge_down_to_memFiber_up_up_bus_a_payload_mask;
  assign bridge_down_to_memFiber_up_down_bus_a_payload_data = bridge_down_to_memFiber_up_up_bus_a_payload_data;
  assign bridge_down_to_memFiber_up_down_bus_a_payload_corrupt = bridge_down_to_memFiber_up_up_bus_a_payload_corrupt;
  assign bridge_down_to_memFiber_up_up_bus_d_valid = bridge_down_to_memFiber_up_down_bus_d_valid;
  assign bridge_down_to_memFiber_up_down_bus_d_ready = bridge_down_to_memFiber_up_up_bus_d_ready;
  assign bridge_down_to_memFiber_up_up_bus_d_payload_opcode = bridge_down_to_memFiber_up_down_bus_d_payload_opcode;
  assign bridge_down_to_memFiber_up_up_bus_d_payload_param = bridge_down_to_memFiber_up_down_bus_d_payload_param;
  assign bridge_down_to_memFiber_up_up_bus_d_payload_source = bridge_down_to_memFiber_up_down_bus_d_payload_source;
  assign bridge_down_to_memFiber_up_up_bus_d_payload_size = bridge_down_to_memFiber_up_down_bus_d_payload_size;
  assign bridge_down_to_memFiber_up_up_bus_d_payload_denied = bridge_down_to_memFiber_up_down_bus_d_payload_denied;
  assign bridge_down_to_memFiber_up_up_bus_d_payload_data = bridge_down_to_memFiber_up_down_bus_d_payload_data;
  assign bridge_down_to_memFiber_up_up_bus_d_payload_corrupt = bridge_down_to_memFiber_up_down_bus_d_payload_corrupt;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      memFiber_thread_logic_pipeline_cmd_fsm_counter <= 1'b0;
      memFiber_thread_logic_pipeline_rsp_valid <= 1'b0;
      memFiber_thread_logic_io_up_a_tracker_beat <= 1'b0;
      memFiber_thread_logic_ordering_regNext_valid <= 1'b0;
    end else begin
      if(memFiber_thread_logic_pipeline_cmd_isFireing) begin
        memFiber_thread_logic_pipeline_cmd_fsm_counter <= (memFiber_thread_logic_pipeline_cmd_fsm_counter + 1'b1);
        if(memFiber_thread_logic_pipeline_cmd_LAST) begin
          memFiber_thread_logic_pipeline_cmd_fsm_counter <= 1'b0;
        end
      end
      if(memFiber_thread_logic_pipeline_cmd_ready_output) begin
        memFiber_thread_logic_pipeline_rsp_valid <= memFiber_thread_logic_pipeline_cmd_valid;
      end
      if(memFiber_thread_logic_io_up_a_fire) begin
        memFiber_thread_logic_io_up_a_tracker_beat <= (memFiber_thread_logic_io_up_a_tracker_beat + 1'b1);
        if(memFiber_thread_logic_io_up_a_tracker_last) begin
          memFiber_thread_logic_io_up_a_tracker_beat <= 1'b0;
        end
      end
      memFiber_thread_logic_ordering_regNext_valid <= memFiber_thread_logic_ordering_valid;
    end
  end

  always @(posedge clk) begin
    if(when_TileLinkAccess_l57) begin
      memFiber_thread_logic_pipeline_cmd_fsm_size <= memFiber_thread_logic_io_up_a_payload_size;
      memFiber_thread_logic_pipeline_cmd_fsm_source <= memFiber_thread_logic_io_up_a_payload_source;
      memFiber_thread_logic_pipeline_cmd_fsm_isGet <= (|(memFiber_thread_logic_io_up_a_payload_opcode == A_GET));
      memFiber_thread_logic_pipeline_cmd_fsm_address <= memFiber_thread_logic_pipeline_cmd_addressShifted;
    end
    if(memFiber_thread_logic_pipeline_cmd_ready_output) begin
      memFiber_thread_logic_pipeline_rsp_cmd_IS_GET <= memFiber_thread_logic_pipeline_cmd_IS_GET;
      memFiber_thread_logic_pipeline_rsp_cmd_SIZE <= memFiber_thread_logic_pipeline_cmd_SIZE;
      memFiber_thread_logic_pipeline_rsp_cmd_SOURCE <= memFiber_thread_logic_pipeline_cmd_SOURCE;
      memFiber_thread_logic_pipeline_rsp_cmd_LAST <= memFiber_thread_logic_pipeline_cmd_LAST;
    end
    memFiber_thread_logic_ordering_regNext_payload_bytes <= memFiber_thread_logic_ordering_payload_bytes;
  end


endmodule

module WidthAdapter_1 (
  input  wire          io_up_a_valid,
  output wire          io_up_a_ready,
  input  wire [2:0]    io_up_a_payload_opcode,
  input  wire [2:0]    io_up_a_payload_param,
  input  wire [1:0]    io_up_a_payload_source,
  input  wire [13:0]   io_up_a_payload_address,
  input  wire [2:0]    io_up_a_payload_size,
  input  wire [3:0]    io_up_a_payload_mask,
  input  wire [31:0]   io_up_a_payload_data,
  input  wire          io_up_a_payload_corrupt,
  output wire          io_up_d_valid,
  input  wire          io_up_d_ready,
  output wire [2:0]    io_up_d_payload_opcode,
  output wire [2:0]    io_up_d_payload_param,
  output wire [1:0]    io_up_d_payload_source,
  output wire [2:0]    io_up_d_payload_size,
  output wire          io_up_d_payload_denied,
  output wire          io_down_a_valid,
  input  wire          io_down_a_ready,
  output wire [2:0]    io_down_a_payload_opcode,
  output wire [2:0]    io_down_a_payload_param,
  output wire [1:0]    io_down_a_payload_source,
  output wire [13:0]   io_down_a_payload_address,
  output wire [2:0]    io_down_a_payload_size,
  output wire [15:0]   io_down_a_payload_mask,
  output wire [127:0]  io_down_a_payload_data,
  output wire          io_down_a_payload_corrupt,
  input  wire          io_down_d_valid,
  output wire          io_down_d_ready,
  input  wire [2:0]    io_down_d_payload_opcode,
  input  wire [2:0]    io_down_d_payload_param,
  input  wire [1:0]    io_down_d_payload_source,
  input  wire [2:0]    io_down_d_payload_size,
  input  wire          io_down_d_payload_denied,
  input  wire          clk,
  input  wire          reset
);
  localparam A_PUT_FULL_DATA = 3'd0;
  localparam A_PUT_PARTIAL_DATA = 3'd1;
  localparam A_GET = 3'd4;
  localparam A_ACQUIRE_BLOCK = 3'd6;
  localparam A_ACQUIRE_PERM = 3'd7;
  localparam D_ACCESS_ACK = 3'd0;
  localparam D_ACCESS_ACK_DATA = 3'd1;
  localparam D_GRANT = 3'd4;
  localparam D_GRANT_DATA = 3'd5;
  localparam D_RELEASE_ACK = 3'd6;

  wire                upsize_d_ctx_io_add_valid;
  wire       [1:0]    upsize_d_ctx_io_add_payload_context;
  wire                upsize_d_ctx_io_remove_valid;
  wire                upsize_d_ctx_io_add_ready;
  wire       [1:0]    upsize_d_ctx_io_query_context;
  reg        [2:0]    _zz_upsize_a_ctrl_burstLast;
  reg        [2:0]    _zz_io_up_a_tracker_last;
  reg                 upsize_iaHalt;
  wire                _zz_io_up_a_ready;
  wire                upsize_ia_valid;
  wire                upsize_ia_ready;
  wire       [2:0]    upsize_ia_payload_opcode;
  wire       [2:0]    upsize_ia_payload_param;
  wire       [1:0]    upsize_ia_payload_source;
  wire       [13:0]   upsize_ia_payload_address;
  wire       [2:0]    upsize_ia_payload_size;
  wire       [3:0]    upsize_ia_payload_mask;
  wire       [31:0]   upsize_ia_payload_data;
  wire                upsize_ia_payload_corrupt;
  wire       [1:0]    _zz_upsize_a_ctrl_wordLast;
  reg        [2:0]    upsize_ia_tracker_beat;
  wire                upsize_a_ctrl_burstLast;
  wire                upsize_ia_fire;
  wire                upsize_a_ctrl_wordLast;
  reg                 upsize_a_ctrl_buffer_valid;
  reg                 upsize_a_ctrl_buffer_first;
  reg        [2:0]    upsize_a_ctrl_buffer_args_opcode;
  reg        [2:0]    upsize_a_ctrl_buffer_args_param;
  reg        [1:0]    upsize_a_ctrl_buffer_args_source;
  reg        [13:0]   upsize_a_ctrl_buffer_args_address;
  reg        [2:0]    upsize_a_ctrl_buffer_args_size;
  reg        [31:0]   upsize_a_ctrl_buffer_data_0;
  reg        [31:0]   upsize_a_ctrl_buffer_data_1;
  reg        [31:0]   upsize_a_ctrl_buffer_data_2;
  reg        [31:0]   upsize_a_ctrl_buffer_data_3;
  reg        [3:0]    upsize_a_ctrl_buffer_mask_0;
  reg        [3:0]    upsize_a_ctrl_buffer_mask_1;
  reg        [3:0]    upsize_a_ctrl_buffer_mask_2;
  reg        [3:0]    upsize_a_ctrl_buffer_mask_3;
  reg                 upsize_a_ctrl_buffer_corrupt;
  wire       [3:0]    _zz_1;
  wire       [3:0]    _zz_2;
  wire                io_up_a_fire;
  reg        [2:0]    io_up_a_tracker_beat;
  wire                io_up_a_tracker_last;
  wire                when_ContextBuffer_l19;
  wire                io_up_d_fire;
  reg        [1:0]    upsize_d_ctrl_counter;
  wire       [1:0]    upsize_d_ctrl_sel;
  wire                upsize_d_ctrl_burstLast;
  `ifndef SYNTHESIS
  reg [127:0] io_up_a_payload_opcode_string;
  reg [119:0] io_up_d_payload_opcode_string;
  reg [127:0] io_down_a_payload_opcode_string;
  reg [119:0] io_down_d_payload_opcode_string;
  reg [127:0] upsize_ia_payload_opcode_string;
  reg [127:0] upsize_a_ctrl_buffer_args_opcode_string;
  `endif


  ContextAsyncBufferFull upsize_d_ctx (
    .io_add_valid           (upsize_d_ctx_io_add_valid               ), //i
    .io_add_ready           (upsize_d_ctx_io_add_ready               ), //o
    .io_add_payload_id      (io_up_a_payload_source[1:0]             ), //i
    .io_add_payload_context (upsize_d_ctx_io_add_payload_context[1:0]), //i
    .io_remove_valid        (upsize_d_ctx_io_remove_valid            ), //i
    .io_remove_payload_id   (io_up_d_payload_source[1:0]             ), //i
    .io_query_id            (io_down_d_payload_source[1:0]           ), //i
    .io_query_context       (upsize_d_ctx_io_query_context[1:0]      ), //o
    .clk                    (clk                                     ), //i
    .reset                  (reset                                   )  //i
  );
  always @(*) begin
    case(upsize_ia_payload_size)
      3'b000 : _zz_upsize_a_ctrl_burstLast = 3'b000;
      3'b001 : _zz_upsize_a_ctrl_burstLast = 3'b000;
      3'b010 : _zz_upsize_a_ctrl_burstLast = 3'b000;
      3'b011 : _zz_upsize_a_ctrl_burstLast = 3'b001;
      3'b100 : _zz_upsize_a_ctrl_burstLast = 3'b011;
      default : _zz_upsize_a_ctrl_burstLast = 3'b111;
    endcase
  end

  always @(*) begin
    case(io_up_a_payload_size)
      3'b000 : _zz_io_up_a_tracker_last = 3'b000;
      3'b001 : _zz_io_up_a_tracker_last = 3'b000;
      3'b010 : _zz_io_up_a_tracker_last = 3'b000;
      3'b011 : _zz_io_up_a_tracker_last = 3'b001;
      3'b100 : _zz_io_up_a_tracker_last = 3'b011;
      default : _zz_io_up_a_tracker_last = 3'b111;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_up_a_payload_opcode)
      A_PUT_FULL_DATA : io_up_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_up_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_up_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_up_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_up_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_up_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_up_d_payload_opcode)
      D_ACCESS_ACK : io_up_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : io_up_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : io_up_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : io_up_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : io_up_d_payload_opcode_string = "RELEASE_ACK    ";
      default : io_up_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(io_down_a_payload_opcode)
      A_PUT_FULL_DATA : io_down_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_down_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_down_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_down_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_down_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_down_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_down_d_payload_opcode)
      D_ACCESS_ACK : io_down_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : io_down_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : io_down_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : io_down_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : io_down_d_payload_opcode_string = "RELEASE_ACK    ";
      default : io_down_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(upsize_ia_payload_opcode)
      A_PUT_FULL_DATA : upsize_ia_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : upsize_ia_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : upsize_ia_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : upsize_ia_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : upsize_ia_payload_opcode_string = "ACQUIRE_PERM    ";
      default : upsize_ia_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(upsize_a_ctrl_buffer_args_opcode)
      A_PUT_FULL_DATA : upsize_a_ctrl_buffer_args_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : upsize_a_ctrl_buffer_args_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : upsize_a_ctrl_buffer_args_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : upsize_a_ctrl_buffer_args_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : upsize_a_ctrl_buffer_args_opcode_string = "ACQUIRE_PERM    ";
      default : upsize_a_ctrl_buffer_args_opcode_string = "????????????????";
    endcase
  end
  `endif

  always @(*) begin
    upsize_iaHalt = 1'b0;
    if(when_ContextBuffer_l19) begin
      upsize_iaHalt = 1'b1;
    end
  end

  assign _zz_io_up_a_ready = (! upsize_iaHalt);
  assign upsize_ia_valid = (io_up_a_valid && _zz_io_up_a_ready);
  assign io_up_a_ready = (upsize_ia_ready && _zz_io_up_a_ready);
  assign upsize_ia_payload_opcode = io_up_a_payload_opcode;
  assign upsize_ia_payload_param = io_up_a_payload_param;
  assign upsize_ia_payload_source = io_up_a_payload_source;
  assign upsize_ia_payload_address = io_up_a_payload_address;
  assign upsize_ia_payload_size = io_up_a_payload_size;
  assign upsize_ia_payload_mask = io_up_a_payload_mask;
  assign upsize_ia_payload_data = io_up_a_payload_data;
  assign upsize_ia_payload_corrupt = io_up_a_payload_corrupt;
  assign _zz_upsize_a_ctrl_wordLast = upsize_ia_payload_address[3 : 2];
  assign upsize_a_ctrl_burstLast = ((! ((1'b0 || (A_PUT_FULL_DATA == upsize_ia_payload_opcode)) || (A_PUT_PARTIAL_DATA == upsize_ia_payload_opcode))) || (upsize_ia_tracker_beat == _zz_upsize_a_ctrl_burstLast));
  assign upsize_ia_fire = (upsize_ia_valid && upsize_ia_ready);
  assign upsize_a_ctrl_wordLast = ((&_zz_upsize_a_ctrl_wordLast) || upsize_a_ctrl_burstLast);
  assign io_down_a_valid = upsize_a_ctrl_buffer_valid;
  assign io_down_a_payload_opcode = upsize_a_ctrl_buffer_args_opcode;
  assign io_down_a_payload_param = upsize_a_ctrl_buffer_args_param;
  assign io_down_a_payload_source = upsize_a_ctrl_buffer_args_source;
  assign io_down_a_payload_address = upsize_a_ctrl_buffer_args_address;
  assign io_down_a_payload_size = upsize_a_ctrl_buffer_args_size;
  assign io_down_a_payload_mask = {upsize_a_ctrl_buffer_mask_3,{upsize_a_ctrl_buffer_mask_2,{upsize_a_ctrl_buffer_mask_1,upsize_a_ctrl_buffer_mask_0}}};
  assign io_down_a_payload_data = {upsize_a_ctrl_buffer_data_3,{upsize_a_ctrl_buffer_data_2,{upsize_a_ctrl_buffer_data_1,upsize_a_ctrl_buffer_data_0}}};
  assign io_down_a_payload_corrupt = upsize_a_ctrl_buffer_corrupt;
  assign upsize_ia_ready = ((! upsize_a_ctrl_buffer_valid) || io_down_a_ready);
  assign _zz_1 = ({3'd0,1'b1} <<< _zz_upsize_a_ctrl_wordLast);
  assign _zz_2 = ({3'd0,1'b1} <<< _zz_upsize_a_ctrl_wordLast);
  assign io_up_a_fire = (io_up_a_valid && io_up_a_ready);
  assign io_up_a_tracker_last = ((! ((1'b0 || (A_PUT_FULL_DATA == io_up_a_payload_opcode)) || (A_PUT_PARTIAL_DATA == io_up_a_payload_opcode))) || (io_up_a_tracker_beat == _zz_io_up_a_tracker_last));
  assign upsize_d_ctx_io_add_valid = (io_up_a_fire && io_up_a_tracker_last);
  assign when_ContextBuffer_l19 = (! upsize_d_ctx_io_add_ready);
  assign io_up_d_fire = (io_up_d_valid && io_up_d_ready);
  assign upsize_d_ctx_io_remove_valid = ((io_up_d_fire && 1'b1) && (|{(io_up_d_payload_opcode == D_GRANT_DATA),{(io_up_d_payload_opcode == D_GRANT),{(io_up_d_payload_opcode == D_ACCESS_ACK_DATA),(io_up_d_payload_opcode == D_ACCESS_ACK)}}}));
  assign upsize_d_ctx_io_add_payload_context = io_up_a_payload_address[3 : 2];
  assign upsize_d_ctrl_sel = (upsize_d_ctrl_counter + upsize_d_ctx_io_query_context);
  assign upsize_d_ctrl_burstLast = 1'b1;
  assign io_up_d_valid = io_down_d_valid;
  assign io_up_d_payload_opcode = io_down_d_payload_opcode;
  assign io_up_d_payload_param = io_down_d_payload_param;
  assign io_up_d_payload_source = io_down_d_payload_source;
  assign io_up_d_payload_size = io_down_d_payload_size;
  assign io_up_d_payload_denied = io_down_d_payload_denied;
  assign io_down_d_ready = (io_up_d_ready && ((&upsize_d_ctrl_counter) || upsize_d_ctrl_burstLast));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      upsize_ia_tracker_beat <= 3'b000;
      upsize_a_ctrl_buffer_valid <= 1'b0;
      upsize_a_ctrl_buffer_first <= 1'b1;
      io_up_a_tracker_beat <= 3'b000;
      upsize_d_ctrl_counter <= 2'b00;
    end else begin
      if(upsize_ia_fire) begin
        upsize_ia_tracker_beat <= (upsize_ia_tracker_beat + 3'b001);
        if(upsize_a_ctrl_burstLast) begin
          upsize_ia_tracker_beat <= 3'b000;
        end
      end
      if(io_down_a_ready) begin
        upsize_a_ctrl_buffer_valid <= 1'b0;
      end
      if(upsize_ia_fire) begin
        upsize_a_ctrl_buffer_valid <= upsize_a_ctrl_wordLast;
        upsize_a_ctrl_buffer_first <= upsize_a_ctrl_wordLast;
      end
      if(io_up_a_fire) begin
        io_up_a_tracker_beat <= (io_up_a_tracker_beat + 3'b001);
        if(io_up_a_tracker_last) begin
          io_up_a_tracker_beat <= 3'b000;
        end
      end
      if(io_up_d_fire) begin
        upsize_d_ctrl_counter <= (upsize_d_ctrl_counter + 2'b01);
        if(upsize_d_ctrl_burstLast) begin
          upsize_d_ctrl_counter <= 2'b00;
        end
      end
    end
  end

  always @(posedge clk) begin
    if(upsize_ia_fire) begin
      if(upsize_a_ctrl_buffer_first) begin
        upsize_a_ctrl_buffer_args_opcode <= upsize_ia_payload_opcode;
        upsize_a_ctrl_buffer_args_param <= upsize_ia_payload_param;
        upsize_a_ctrl_buffer_args_source <= upsize_ia_payload_source;
        upsize_a_ctrl_buffer_args_address <= upsize_ia_payload_address;
        upsize_a_ctrl_buffer_args_size <= upsize_ia_payload_size;
        upsize_a_ctrl_buffer_corrupt <= 1'b0;
        upsize_a_ctrl_buffer_mask_0 <= 4'b0000;
        upsize_a_ctrl_buffer_mask_1 <= 4'b0000;
        upsize_a_ctrl_buffer_mask_2 <= 4'b0000;
        upsize_a_ctrl_buffer_mask_3 <= 4'b0000;
      end
      if(_zz_1[0]) begin
        upsize_a_ctrl_buffer_data_0 <= upsize_ia_payload_data;
      end
      if(_zz_1[1]) begin
        upsize_a_ctrl_buffer_data_1 <= upsize_ia_payload_data;
      end
      if(_zz_1[2]) begin
        upsize_a_ctrl_buffer_data_2 <= upsize_ia_payload_data;
      end
      if(_zz_1[3]) begin
        upsize_a_ctrl_buffer_data_3 <= upsize_ia_payload_data;
      end
      if(_zz_2[0]) begin
        upsize_a_ctrl_buffer_mask_0 <= upsize_ia_payload_mask;
      end
      if(_zz_2[1]) begin
        upsize_a_ctrl_buffer_mask_1 <= upsize_ia_payload_mask;
      end
      if(_zz_2[2]) begin
        upsize_a_ctrl_buffer_mask_2 <= upsize_ia_payload_mask;
      end
      if(_zz_2[3]) begin
        upsize_a_ctrl_buffer_mask_3 <= upsize_ia_payload_mask;
      end
      if(upsize_ia_payload_corrupt) begin
        upsize_a_ctrl_buffer_corrupt <= 1'b1;
      end
    end
  end


endmodule

module WidthAdapter (
  input  wire          io_up_a_valid,
  output wire          io_up_a_ready,
  input  wire [2:0]    io_up_a_payload_opcode,
  input  wire [2:0]    io_up_a_payload_param,
  input  wire [1:0]    io_up_a_payload_source,
  input  wire [13:0]   io_up_a_payload_address,
  input  wire [2:0]    io_up_a_payload_size,
  output wire          io_up_d_valid,
  input  wire          io_up_d_ready,
  output wire [2:0]    io_up_d_payload_opcode,
  output wire [2:0]    io_up_d_payload_param,
  output wire [1:0]    io_up_d_payload_source,
  output wire [2:0]    io_up_d_payload_size,
  output wire          io_up_d_payload_denied,
  output wire [31:0]   io_up_d_payload_data,
  output wire          io_up_d_payload_corrupt,
  output wire          io_down_a_valid,
  input  wire          io_down_a_ready,
  output wire [2:0]    io_down_a_payload_opcode,
  output wire [2:0]    io_down_a_payload_param,
  output wire [1:0]    io_down_a_payload_source,
  output wire [13:0]   io_down_a_payload_address,
  output wire [2:0]    io_down_a_payload_size,
  input  wire          io_down_d_valid,
  output wire          io_down_d_ready,
  input  wire [2:0]    io_down_d_payload_opcode,
  input  wire [2:0]    io_down_d_payload_param,
  input  wire [1:0]    io_down_d_payload_source,
  input  wire [2:0]    io_down_d_payload_size,
  input  wire          io_down_d_payload_denied,
  input  wire [127:0]  io_down_d_payload_data,
  input  wire          io_down_d_payload_corrupt,
  input  wire          clk,
  input  wire          reset
);
  localparam A_PUT_FULL_DATA = 3'd0;
  localparam A_PUT_PARTIAL_DATA = 3'd1;
  localparam A_GET = 3'd4;
  localparam A_ACQUIRE_BLOCK = 3'd6;
  localparam A_ACQUIRE_PERM = 3'd7;
  localparam D_ACCESS_ACK = 3'd0;
  localparam D_ACCESS_ACK_DATA = 3'd1;
  localparam D_GRANT = 3'd4;
  localparam D_GRANT_DATA = 3'd5;
  localparam D_RELEASE_ACK = 3'd6;

  wire                upsize_d_ctx_io_add_valid;
  wire       [1:0]    upsize_d_ctx_io_add_payload_context;
  wire                upsize_d_ctx_io_remove_valid;
  wire                upsize_d_ctx_io_add_ready;
  wire       [1:0]    upsize_d_ctx_io_query_context;
  reg        [2:0]    _zz_upsize_d_ctrl_burstLast;
  reg        [31:0]   _zz_io_up_d_payload_data;
  reg                 upsize_iaHalt;
  wire                _zz_io_up_a_ready;
  wire                upsize_ia_valid;
  wire                upsize_ia_ready;
  wire       [2:0]    upsize_ia_payload_opcode;
  wire       [2:0]    upsize_ia_payload_param;
  wire       [1:0]    upsize_ia_payload_source;
  wire       [13:0]   upsize_ia_payload_address;
  wire       [2:0]    upsize_ia_payload_size;
  wire                io_up_a_fire;
  wire                when_ContextBuffer_l19;
  wire                io_up_d_fire;
  reg        [2:0]    io_up_d_tracker_beat;
  wire                upsize_d_ctrl_burstLast;
  reg        [1:0]    upsize_d_ctrl_counter;
  wire       [1:0]    upsize_d_ctrl_sel;
  `ifndef SYNTHESIS
  reg [127:0] io_up_a_payload_opcode_string;
  reg [119:0] io_up_d_payload_opcode_string;
  reg [127:0] io_down_a_payload_opcode_string;
  reg [119:0] io_down_d_payload_opcode_string;
  reg [127:0] upsize_ia_payload_opcode_string;
  `endif


  ContextAsyncBufferFull upsize_d_ctx (
    .io_add_valid           (upsize_d_ctx_io_add_valid               ), //i
    .io_add_ready           (upsize_d_ctx_io_add_ready               ), //o
    .io_add_payload_id      (io_up_a_payload_source[1:0]             ), //i
    .io_add_payload_context (upsize_d_ctx_io_add_payload_context[1:0]), //i
    .io_remove_valid        (upsize_d_ctx_io_remove_valid            ), //i
    .io_remove_payload_id   (io_up_d_payload_source[1:0]             ), //i
    .io_query_id            (io_down_d_payload_source[1:0]           ), //i
    .io_query_context       (upsize_d_ctx_io_query_context[1:0]      ), //o
    .clk                    (clk                                     ), //i
    .reset                  (reset                                   )  //i
  );
  always @(*) begin
    case(io_up_d_payload_size)
      3'b000 : _zz_upsize_d_ctrl_burstLast = 3'b000;
      3'b001 : _zz_upsize_d_ctrl_burstLast = 3'b000;
      3'b010 : _zz_upsize_d_ctrl_burstLast = 3'b000;
      3'b011 : _zz_upsize_d_ctrl_burstLast = 3'b001;
      3'b100 : _zz_upsize_d_ctrl_burstLast = 3'b011;
      default : _zz_upsize_d_ctrl_burstLast = 3'b111;
    endcase
  end

  always @(*) begin
    case(upsize_d_ctrl_sel)
      2'b00 : _zz_io_up_d_payload_data = io_down_d_payload_data[31 : 0];
      2'b01 : _zz_io_up_d_payload_data = io_down_d_payload_data[63 : 32];
      2'b10 : _zz_io_up_d_payload_data = io_down_d_payload_data[95 : 64];
      default : _zz_io_up_d_payload_data = io_down_d_payload_data[127 : 96];
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_up_a_payload_opcode)
      A_PUT_FULL_DATA : io_up_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_up_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_up_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_up_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_up_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_up_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_up_d_payload_opcode)
      D_ACCESS_ACK : io_up_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : io_up_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : io_up_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : io_up_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : io_up_d_payload_opcode_string = "RELEASE_ACK    ";
      default : io_up_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(io_down_a_payload_opcode)
      A_PUT_FULL_DATA : io_down_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_down_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_down_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_down_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_down_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_down_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_down_d_payload_opcode)
      D_ACCESS_ACK : io_down_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : io_down_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : io_down_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : io_down_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : io_down_d_payload_opcode_string = "RELEASE_ACK    ";
      default : io_down_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(upsize_ia_payload_opcode)
      A_PUT_FULL_DATA : upsize_ia_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : upsize_ia_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : upsize_ia_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : upsize_ia_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : upsize_ia_payload_opcode_string = "ACQUIRE_PERM    ";
      default : upsize_ia_payload_opcode_string = "????????????????";
    endcase
  end
  `endif

  always @(*) begin
    upsize_iaHalt = 1'b0;
    if(when_ContextBuffer_l19) begin
      upsize_iaHalt = 1'b1;
    end
  end

  assign _zz_io_up_a_ready = (! upsize_iaHalt);
  assign upsize_ia_valid = (io_up_a_valid && _zz_io_up_a_ready);
  assign io_up_a_ready = (upsize_ia_ready && _zz_io_up_a_ready);
  assign upsize_ia_payload_opcode = io_up_a_payload_opcode;
  assign upsize_ia_payload_param = io_up_a_payload_param;
  assign upsize_ia_payload_source = io_up_a_payload_source;
  assign upsize_ia_payload_address = io_up_a_payload_address;
  assign upsize_ia_payload_size = io_up_a_payload_size;
  assign io_down_a_valid = upsize_ia_valid;
  assign upsize_ia_ready = io_down_a_ready;
  assign io_down_a_payload_opcode = upsize_ia_payload_opcode;
  assign io_down_a_payload_param = upsize_ia_payload_param;
  assign io_down_a_payload_source = upsize_ia_payload_source;
  assign io_down_a_payload_address = upsize_ia_payload_address;
  assign io_down_a_payload_size = upsize_ia_payload_size;
  assign io_up_a_fire = (io_up_a_valid && io_up_a_ready);
  assign upsize_d_ctx_io_add_valid = (io_up_a_fire && 1'b1);
  assign when_ContextBuffer_l19 = (! upsize_d_ctx_io_add_ready);
  assign io_up_d_fire = (io_up_d_valid && io_up_d_ready);
  assign upsize_d_ctrl_burstLast = ((! ((1'b0 || (D_ACCESS_ACK_DATA == io_up_d_payload_opcode)) || (D_GRANT_DATA == io_up_d_payload_opcode))) || (io_up_d_tracker_beat == _zz_upsize_d_ctrl_burstLast));
  assign upsize_d_ctx_io_remove_valid = ((io_up_d_fire && upsize_d_ctrl_burstLast) && (|{(io_up_d_payload_opcode == D_GRANT_DATA),{(io_up_d_payload_opcode == D_GRANT),{(io_up_d_payload_opcode == D_ACCESS_ACK_DATA),(io_up_d_payload_opcode == D_ACCESS_ACK)}}}));
  assign upsize_d_ctx_io_add_payload_context = io_up_a_payload_address[3 : 2];
  assign upsize_d_ctrl_sel = (upsize_d_ctrl_counter + upsize_d_ctx_io_query_context);
  assign io_up_d_valid = io_down_d_valid;
  assign io_up_d_payload_opcode = io_down_d_payload_opcode;
  assign io_up_d_payload_param = io_down_d_payload_param;
  assign io_up_d_payload_source = io_down_d_payload_source;
  assign io_up_d_payload_size = io_down_d_payload_size;
  assign io_up_d_payload_denied = io_down_d_payload_denied;
  assign io_up_d_payload_corrupt = io_down_d_payload_corrupt;
  assign io_down_d_ready = (io_up_d_ready && ((&upsize_d_ctrl_counter) || upsize_d_ctrl_burstLast));
  assign io_up_d_payload_data = _zz_io_up_d_payload_data;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      io_up_d_tracker_beat <= 3'b000;
      upsize_d_ctrl_counter <= 2'b00;
    end else begin
      if(io_up_d_fire) begin
        io_up_d_tracker_beat <= (io_up_d_tracker_beat + 3'b001);
        if(upsize_d_ctrl_burstLast) begin
          io_up_d_tracker_beat <= 3'b000;
        end
      end
      if(io_up_d_fire) begin
        upsize_d_ctrl_counter <= (upsize_d_ctrl_counter + 2'b01);
        if(upsize_d_ctrl_burstLast) begin
          upsize_d_ctrl_counter <= 2'b00;
        end
      end
    end
  end


endmodule

module Arbiter (
  input  wire          io_ups_0_a_valid,
  output wire          io_ups_0_a_ready,
  input  wire [2:0]    io_ups_0_a_payload_opcode,
  input  wire [2:0]    io_ups_0_a_payload_param,
  input  wire [1:0]    io_ups_0_a_payload_source,
  input  wire [13:0]   io_ups_0_a_payload_address,
  input  wire [2:0]    io_ups_0_a_payload_size,
  output wire          io_ups_0_d_valid,
  input  wire          io_ups_0_d_ready,
  output wire [2:0]    io_ups_0_d_payload_opcode,
  output wire [2:0]    io_ups_0_d_payload_param,
  output wire [1:0]    io_ups_0_d_payload_source,
  output wire [2:0]    io_ups_0_d_payload_size,
  output wire          io_ups_0_d_payload_denied,
  output wire [127:0]  io_ups_0_d_payload_data,
  output wire          io_ups_0_d_payload_corrupt,
  input  wire          io_ups_1_a_valid,
  output wire          io_ups_1_a_ready,
  input  wire [2:0]    io_ups_1_a_payload_opcode,
  input  wire [2:0]    io_ups_1_a_payload_param,
  input  wire [1:0]    io_ups_1_a_payload_source,
  input  wire [13:0]   io_ups_1_a_payload_address,
  input  wire [2:0]    io_ups_1_a_payload_size,
  input  wire [15:0]   io_ups_1_a_payload_mask,
  input  wire [127:0]  io_ups_1_a_payload_data,
  input  wire          io_ups_1_a_payload_corrupt,
  output wire          io_ups_1_d_valid,
  input  wire          io_ups_1_d_ready,
  output wire [2:0]    io_ups_1_d_payload_opcode,
  output wire [2:0]    io_ups_1_d_payload_param,
  output wire [1:0]    io_ups_1_d_payload_source,
  output wire [2:0]    io_ups_1_d_payload_size,
  output wire          io_ups_1_d_payload_denied,
  output wire          io_down_a_valid,
  input  wire          io_down_a_ready,
  output wire [2:0]    io_down_a_payload_opcode,
  output wire [2:0]    io_down_a_payload_param,
  output wire [2:0]    io_down_a_payload_source,
  output wire [13:0]   io_down_a_payload_address,
  output wire [2:0]    io_down_a_payload_size,
  output wire [15:0]   io_down_a_payload_mask,
  output wire [127:0]  io_down_a_payload_data,
  output wire          io_down_a_payload_corrupt,
  input  wire          io_down_d_valid,
  output wire          io_down_d_ready,
  input  wire [2:0]    io_down_d_payload_opcode,
  input  wire [2:0]    io_down_d_payload_param,
  input  wire [2:0]    io_down_d_payload_source,
  input  wire [2:0]    io_down_d_payload_size,
  input  wire          io_down_d_payload_denied,
  input  wire [127:0]  io_down_d_payload_data,
  input  wire          io_down_d_payload_corrupt,
  input  wire          clk,
  input  wire          reset
);
  localparam A_PUT_FULL_DATA = 3'd0;
  localparam A_PUT_PARTIAL_DATA = 3'd1;
  localparam A_GET = 3'd4;
  localparam A_ACQUIRE_BLOCK = 3'd6;
  localparam A_ACQUIRE_PERM = 3'd7;
  localparam D_ACCESS_ACK = 3'd0;
  localparam D_ACCESS_ACK_DATA = 3'd1;
  localparam D_GRANT = 3'd4;
  localparam D_GRANT_DATA = 3'd5;
  localparam D_RELEASE_ACK = 3'd6;

  wire                a_arbiter_io_inputs_0_ready;
  wire                a_arbiter_io_inputs_1_ready;
  wire                a_arbiter_io_output_valid;
  wire       [2:0]    a_arbiter_io_output_payload_opcode;
  wire       [2:0]    a_arbiter_io_output_payload_param;
  wire       [2:0]    a_arbiter_io_output_payload_source;
  wire       [13:0]   a_arbiter_io_output_payload_address;
  wire       [2:0]    a_arbiter_io_output_payload_size;
  wire       [15:0]   a_arbiter_io_output_payload_mask;
  wire       [127:0]  a_arbiter_io_output_payload_data;
  wire                a_arbiter_io_output_payload_corrupt;
  wire       [0:0]    a_arbiter_io_chosen;
  wire       [1:0]    a_arbiter_io_chosenOH;
  wire       [2:0]    _zz_ups_0_a_payload_source;
  wire       [2:0]    _zz_ups_1_a_payload_source;
  reg                 _zz_io_down_d_ready;
  wire                ups_0_a_valid;
  wire                ups_0_a_ready;
  wire       [2:0]    ups_0_a_payload_opcode;
  wire       [2:0]    ups_0_a_payload_param;
  wire       [2:0]    ups_0_a_payload_source;
  wire       [13:0]   ups_0_a_payload_address;
  wire       [2:0]    ups_0_a_payload_size;
  wire                ups_0_d_valid;
  wire                ups_0_d_ready;
  wire       [2:0]    ups_0_d_payload_opcode;
  wire       [2:0]    ups_0_d_payload_param;
  wire       [2:0]    ups_0_d_payload_source;
  wire       [2:0]    ups_0_d_payload_size;
  wire                ups_0_d_payload_denied;
  wire       [127:0]  ups_0_d_payload_data;
  wire                ups_0_d_payload_corrupt;
  wire                ups_1_a_valid;
  wire                ups_1_a_ready;
  wire       [2:0]    ups_1_a_payload_opcode;
  wire       [2:0]    ups_1_a_payload_param;
  wire       [2:0]    ups_1_a_payload_source;
  wire       [13:0]   ups_1_a_payload_address;
  wire       [2:0]    ups_1_a_payload_size;
  wire       [15:0]   ups_1_a_payload_mask;
  wire       [127:0]  ups_1_a_payload_data;
  wire                ups_1_a_payload_corrupt;
  wire                ups_1_d_valid;
  wire                ups_1_d_ready;
  wire       [2:0]    ups_1_d_payload_opcode;
  wire       [2:0]    ups_1_d_payload_param;
  wire       [2:0]    ups_1_d_payload_source;
  wire       [2:0]    ups_1_d_payload_size;
  wire                ups_1_d_payload_denied;
  wire       [0:0]    d_sel;
  `ifndef SYNTHESIS
  reg [127:0] io_ups_0_a_payload_opcode_string;
  reg [119:0] io_ups_0_d_payload_opcode_string;
  reg [127:0] io_ups_1_a_payload_opcode_string;
  reg [119:0] io_ups_1_d_payload_opcode_string;
  reg [127:0] io_down_a_payload_opcode_string;
  reg [119:0] io_down_d_payload_opcode_string;
  reg [127:0] ups_0_a_payload_opcode_string;
  reg [119:0] ups_0_d_payload_opcode_string;
  reg [127:0] ups_1_a_payload_opcode_string;
  reg [119:0] ups_1_d_payload_opcode_string;
  `endif


  assign _zz_ups_0_a_payload_source = {1'd0, io_ups_0_a_payload_source};
  assign _zz_ups_1_a_payload_source = {1'd0, io_ups_1_a_payload_source};
  StreamArbiter a_arbiter (
    .io_inputs_0_valid           (ups_0_a_valid                                                                                                                        ), //i
    .io_inputs_0_ready           (a_arbiter_io_inputs_0_ready                                                                                                          ), //o
    .io_inputs_0_payload_opcode  (ups_0_a_payload_opcode[2:0]                                                                                                          ), //i
    .io_inputs_0_payload_param   (ups_0_a_payload_param[2:0]                                                                                                           ), //i
    .io_inputs_0_payload_source  (ups_0_a_payload_source[2:0]                                                                                                          ), //i
    .io_inputs_0_payload_address (ups_0_a_payload_address[13:0]                                                                                                        ), //i
    .io_inputs_0_payload_size    (ups_0_a_payload_size[2:0]                                                                                                            ), //i
    .io_inputs_0_payload_mask    (16'bxxxxxxxxxxxxxxxx                                                                                                                 ), //i
    .io_inputs_0_payload_data    (128'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx), //i
    .io_inputs_0_payload_corrupt (1'b0                                                                                                                                 ), //i
    .io_inputs_1_valid           (ups_1_a_valid                                                                                                                        ), //i
    .io_inputs_1_ready           (a_arbiter_io_inputs_1_ready                                                                                                          ), //o
    .io_inputs_1_payload_opcode  (ups_1_a_payload_opcode[2:0]                                                                                                          ), //i
    .io_inputs_1_payload_param   (ups_1_a_payload_param[2:0]                                                                                                           ), //i
    .io_inputs_1_payload_source  (ups_1_a_payload_source[2:0]                                                                                                          ), //i
    .io_inputs_1_payload_address (ups_1_a_payload_address[13:0]                                                                                                        ), //i
    .io_inputs_1_payload_size    (ups_1_a_payload_size[2:0]                                                                                                            ), //i
    .io_inputs_1_payload_mask    (ups_1_a_payload_mask[15:0]                                                                                                           ), //i
    .io_inputs_1_payload_data    (ups_1_a_payload_data[127:0]                                                                                                          ), //i
    .io_inputs_1_payload_corrupt (ups_1_a_payload_corrupt                                                                                                              ), //i
    .io_output_valid             (a_arbiter_io_output_valid                                                                                                            ), //o
    .io_output_ready             (io_down_a_ready                                                                                                                      ), //i
    .io_output_payload_opcode    (a_arbiter_io_output_payload_opcode[2:0]                                                                                              ), //o
    .io_output_payload_param     (a_arbiter_io_output_payload_param[2:0]                                                                                               ), //o
    .io_output_payload_source    (a_arbiter_io_output_payload_source[2:0]                                                                                              ), //o
    .io_output_payload_address   (a_arbiter_io_output_payload_address[13:0]                                                                                            ), //o
    .io_output_payload_size      (a_arbiter_io_output_payload_size[2:0]                                                                                                ), //o
    .io_output_payload_mask      (a_arbiter_io_output_payload_mask[15:0]                                                                                               ), //o
    .io_output_payload_data      (a_arbiter_io_output_payload_data[127:0]                                                                                              ), //o
    .io_output_payload_corrupt   (a_arbiter_io_output_payload_corrupt                                                                                                  ), //o
    .io_chosen                   (a_arbiter_io_chosen                                                                                                                  ), //o
    .io_chosenOH                 (a_arbiter_io_chosenOH[1:0]                                                                                                           ), //o
    .clk                         (clk                                                                                                                                  ), //i
    .reset                       (reset                                                                                                                                )  //i
  );
  always @(*) begin
    case(d_sel)
      1'b0 : _zz_io_down_d_ready = ups_0_d_ready;
      default : _zz_io_down_d_ready = ups_1_d_ready;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_ups_0_a_payload_opcode)
      A_PUT_FULL_DATA : io_ups_0_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_ups_0_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_ups_0_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_ups_0_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_ups_0_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_ups_0_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_ups_0_d_payload_opcode)
      D_ACCESS_ACK : io_ups_0_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : io_ups_0_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : io_ups_0_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : io_ups_0_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : io_ups_0_d_payload_opcode_string = "RELEASE_ACK    ";
      default : io_ups_0_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(io_ups_1_a_payload_opcode)
      A_PUT_FULL_DATA : io_ups_1_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_ups_1_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_ups_1_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_ups_1_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_ups_1_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_ups_1_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_ups_1_d_payload_opcode)
      D_ACCESS_ACK : io_ups_1_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : io_ups_1_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : io_ups_1_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : io_ups_1_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : io_ups_1_d_payload_opcode_string = "RELEASE_ACK    ";
      default : io_ups_1_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(io_down_a_payload_opcode)
      A_PUT_FULL_DATA : io_down_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_down_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_down_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_down_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_down_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_down_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_down_d_payload_opcode)
      D_ACCESS_ACK : io_down_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : io_down_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : io_down_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : io_down_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : io_down_d_payload_opcode_string = "RELEASE_ACK    ";
      default : io_down_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(ups_0_a_payload_opcode)
      A_PUT_FULL_DATA : ups_0_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : ups_0_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : ups_0_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : ups_0_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : ups_0_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : ups_0_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(ups_0_d_payload_opcode)
      D_ACCESS_ACK : ups_0_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : ups_0_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : ups_0_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : ups_0_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : ups_0_d_payload_opcode_string = "RELEASE_ACK    ";
      default : ups_0_d_payload_opcode_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(ups_1_a_payload_opcode)
      A_PUT_FULL_DATA : ups_1_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : ups_1_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : ups_1_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : ups_1_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : ups_1_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : ups_1_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(ups_1_d_payload_opcode)
      D_ACCESS_ACK : ups_1_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : ups_1_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : ups_1_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : ups_1_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : ups_1_d_payload_opcode_string = "RELEASE_ACK    ";
      default : ups_1_d_payload_opcode_string = "???????????????";
    endcase
  end
  `endif

  assign ups_0_a_valid = io_ups_0_a_valid;
  assign io_ups_0_a_ready = ups_0_a_ready;
  assign ups_0_a_payload_opcode = io_ups_0_a_payload_opcode;
  assign ups_0_a_payload_param = io_ups_0_a_payload_param;
  assign ups_0_a_payload_address = io_ups_0_a_payload_address;
  assign ups_0_a_payload_size = io_ups_0_a_payload_size;
  assign io_ups_0_d_valid = ups_0_d_valid;
  assign ups_0_d_ready = io_ups_0_d_ready;
  assign io_ups_0_d_payload_opcode = ups_0_d_payload_opcode;
  assign io_ups_0_d_payload_param = ups_0_d_payload_param;
  assign io_ups_0_d_payload_size = ups_0_d_payload_size;
  assign io_ups_0_d_payload_denied = ups_0_d_payload_denied;
  assign io_ups_0_d_payload_data = ups_0_d_payload_data;
  assign io_ups_0_d_payload_corrupt = ups_0_d_payload_corrupt;
  assign ups_0_a_payload_source = (_zz_ups_0_a_payload_source | 3'b000);
  assign io_ups_0_d_payload_source = ups_0_d_payload_source[1:0];
  assign ups_1_a_valid = io_ups_1_a_valid;
  assign io_ups_1_a_ready = ups_1_a_ready;
  assign ups_1_a_payload_opcode = io_ups_1_a_payload_opcode;
  assign ups_1_a_payload_param = io_ups_1_a_payload_param;
  assign ups_1_a_payload_address = io_ups_1_a_payload_address;
  assign ups_1_a_payload_size = io_ups_1_a_payload_size;
  assign ups_1_a_payload_mask = io_ups_1_a_payload_mask;
  assign ups_1_a_payload_data = io_ups_1_a_payload_data;
  assign ups_1_a_payload_corrupt = io_ups_1_a_payload_corrupt;
  assign io_ups_1_d_valid = ups_1_d_valid;
  assign ups_1_d_ready = io_ups_1_d_ready;
  assign io_ups_1_d_payload_opcode = ups_1_d_payload_opcode;
  assign io_ups_1_d_payload_param = ups_1_d_payload_param;
  assign io_ups_1_d_payload_size = ups_1_d_payload_size;
  assign io_ups_1_d_payload_denied = ups_1_d_payload_denied;
  assign ups_1_a_payload_source = (_zz_ups_1_a_payload_source | 3'b100);
  assign io_ups_1_d_payload_source = ups_1_d_payload_source[1:0];
  assign ups_0_a_ready = a_arbiter_io_inputs_0_ready;
  assign ups_1_a_ready = a_arbiter_io_inputs_1_ready;
  assign io_down_a_valid = a_arbiter_io_output_valid;
  assign io_down_a_payload_opcode = a_arbiter_io_output_payload_opcode;
  assign io_down_a_payload_param = a_arbiter_io_output_payload_param;
  assign io_down_a_payload_source = a_arbiter_io_output_payload_source;
  assign io_down_a_payload_address = a_arbiter_io_output_payload_address;
  assign io_down_a_payload_size = a_arbiter_io_output_payload_size;
  assign io_down_a_payload_mask = a_arbiter_io_output_payload_mask;
  assign io_down_a_payload_data = a_arbiter_io_output_payload_data;
  assign io_down_a_payload_corrupt = a_arbiter_io_output_payload_corrupt;
  assign d_sel = io_down_d_payload_source[2 : 2];
  assign io_down_d_ready = _zz_io_down_d_ready;
  assign ups_0_d_valid = (io_down_d_valid && (d_sel == 1'b0));
  assign ups_0_d_payload_opcode = io_down_d_payload_opcode;
  assign ups_0_d_payload_param = io_down_d_payload_param;
  assign ups_0_d_payload_source = io_down_d_payload_source;
  assign ups_0_d_payload_denied = io_down_d_payload_denied;
  assign ups_0_d_payload_size = io_down_d_payload_size;
  assign ups_0_d_payload_data = io_down_d_payload_data;
  assign ups_0_d_payload_corrupt = io_down_d_payload_corrupt;
  assign ups_1_d_valid = (io_down_d_valid && (d_sel == 1'b1));
  assign ups_1_d_payload_opcode = io_down_d_payload_opcode;
  assign ups_1_d_payload_param = io_down_d_payload_param;
  assign ups_1_d_payload_source = io_down_d_payload_source;
  assign ups_1_d_payload_denied = io_down_d_payload_denied;
  assign ups_1_d_payload_size = io_down_d_payload_size;

endmodule

module Axi4WriteOnlyToTilelinkFull (
  input  wire          io_up_aw_valid,
  output wire          io_up_aw_ready,
  input  wire [31:0]   io_up_aw_payload_addr,
  input  wire [3:0]    io_up_aw_payload_id,
  input  wire [3:0]    io_up_aw_payload_region,
  input  wire [7:0]    io_up_aw_payload_len,
  input  wire [2:0]    io_up_aw_payload_size,
  input  wire [1:0]    io_up_aw_payload_burst,
  input  wire [0:0]    io_up_aw_payload_lock,
  input  wire [3:0]    io_up_aw_payload_cache,
  input  wire [3:0]    io_up_aw_payload_qos,
  input  wire [2:0]    io_up_aw_payload_prot,
  input  wire          io_up_w_valid,
  output wire          io_up_w_ready,
  input  wire [31:0]   io_up_w_payload_data,
  input  wire [3:0]    io_up_w_payload_strb,
  input  wire          io_up_w_payload_last,
  output wire          io_up_b_valid,
  input  wire          io_up_b_ready,
  output wire [3:0]    io_up_b_payload_id,
  output wire [1:0]    io_up_b_payload_resp,
  output wire          io_down_a_valid,
  input  wire          io_down_a_ready,
  output wire [2:0]    io_down_a_payload_opcode,
  output wire [2:0]    io_down_a_payload_param,
  output wire [1:0]    io_down_a_payload_source,
  output wire [31:0]   io_down_a_payload_address,
  output wire [2:0]    io_down_a_payload_size,
  output wire [3:0]    io_down_a_payload_mask,
  output wire [31:0]   io_down_a_payload_data,
  output wire          io_down_a_payload_corrupt,
  input  wire          io_down_d_valid,
  output wire          io_down_d_ready,
  input  wire [2:0]    io_down_d_payload_opcode,
  input  wire [2:0]    io_down_d_payload_param,
  input  wire [1:0]    io_down_d_payload_source,
  input  wire [2:0]    io_down_d_payload_size,
  input  wire          io_down_d_payload_denied,
  input  wire          clk,
  input  wire          reset
);
  localparam A_PUT_FULL_DATA = 3'd0;
  localparam A_PUT_PARTIAL_DATA = 3'd1;
  localparam A_GET = 3'd4;
  localparam A_ACQUIRE_BLOCK = 3'd6;
  localparam A_ACQUIRE_PERM = 3'd7;
  localparam D_ACCESS_ACK = 3'd0;
  localparam D_ACCESS_ACK_DATA = 3'd1;
  localparam D_GRANT = 3'd4;
  localparam D_GRANT_DATA = 3'd5;
  localparam D_RELEASE_ACK = 3'd6;

  wire                onePerId_io_up_aw_ready;
  wire                onePerId_io_up_w_ready;
  wire                onePerId_io_up_b_valid;
  wire       [3:0]    onePerId_io_up_b_payload_id;
  wire       [1:0]    onePerId_io_up_b_payload_resp;
  wire                onePerId_io_down_aw_valid;
  wire       [31:0]   onePerId_io_down_aw_payload_addr;
  wire       [3:0]    onePerId_io_down_aw_payload_id;
  wire       [3:0]    onePerId_io_down_aw_payload_region;
  wire       [7:0]    onePerId_io_down_aw_payload_len;
  wire       [2:0]    onePerId_io_down_aw_payload_size;
  wire       [1:0]    onePerId_io_down_aw_payload_burst;
  wire       [0:0]    onePerId_io_down_aw_payload_lock;
  wire       [3:0]    onePerId_io_down_aw_payload_cache;
  wire       [3:0]    onePerId_io_down_aw_payload_qos;
  wire       [2:0]    onePerId_io_down_aw_payload_prot;
  wire                onePerId_io_down_w_valid;
  wire       [31:0]   onePerId_io_down_w_payload_data;
  wire       [3:0]    onePerId_io_down_w_payload_strb;
  wire                onePerId_io_down_w_payload_last;
  wire                onePerId_io_down_b_ready;
  wire                compactor_io_up_aw_ready;
  wire                compactor_io_up_w_ready;
  wire                compactor_io_up_b_valid;
  wire       [3:0]    compactor_io_up_b_payload_id;
  wire       [1:0]    compactor_io_up_b_payload_resp;
  wire                compactor_io_down_aw_valid;
  wire       [31:0]   compactor_io_down_aw_payload_addr;
  wire       [3:0]    compactor_io_down_aw_payload_id;
  wire       [3:0]    compactor_io_down_aw_payload_region;
  wire       [7:0]    compactor_io_down_aw_payload_len;
  wire       [2:0]    compactor_io_down_aw_payload_size;
  wire       [1:0]    compactor_io_down_aw_payload_burst;
  wire       [0:0]    compactor_io_down_aw_payload_lock;
  wire       [3:0]    compactor_io_down_aw_payload_cache;
  wire       [3:0]    compactor_io_down_aw_payload_qos;
  wire       [2:0]    compactor_io_down_aw_payload_prot;
  wire                compactor_io_down_w_valid;
  wire       [31:0]   compactor_io_down_w_payload_data;
  wire       [3:0]    compactor_io_down_w_payload_strb;
  wire                compactor_io_down_w_payload_last;
  wire                compactor_io_down_b_ready;
  wire                aligner_io_up_aw_ready;
  wire                aligner_io_up_w_ready;
  wire                aligner_io_up_b_valid;
  wire       [3:0]    aligner_io_up_b_payload_id;
  wire       [1:0]    aligner_io_up_b_payload_resp;
  wire                aligner_io_down_aw_valid;
  wire       [31:0]   aligner_io_down_aw_payload_addr;
  wire       [1:0]    aligner_io_down_aw_payload_id;
  wire       [3:0]    aligner_io_down_aw_payload_region;
  wire       [7:0]    aligner_io_down_aw_payload_len;
  wire       [2:0]    aligner_io_down_aw_payload_size;
  wire       [1:0]    aligner_io_down_aw_payload_burst;
  wire       [0:0]    aligner_io_down_aw_payload_lock;
  wire       [3:0]    aligner_io_down_aw_payload_cache;
  wire       [3:0]    aligner_io_down_aw_payload_qos;
  wire       [2:0]    aligner_io_down_aw_payload_prot;
  wire                aligner_io_down_w_valid;
  wire       [31:0]   aligner_io_down_w_payload_data;
  wire       [3:0]    aligner_io_down_w_payload_strb;
  wire                aligner_io_down_w_payload_last;
  wire                aligner_io_down_b_ready;
  wire                toTileink_io_up_aw_ready;
  wire                toTileink_io_up_w_ready;
  wire                toTileink_io_up_b_valid;
  wire       [1:0]    toTileink_io_up_b_payload_id;
  wire       [1:0]    toTileink_io_up_b_payload_resp;
  wire                toTileink_io_down_a_valid;
  wire       [2:0]    toTileink_io_down_a_payload_opcode;
  wire       [2:0]    toTileink_io_down_a_payload_param;
  wire       [1:0]    toTileink_io_down_a_payload_source;
  wire       [31:0]   toTileink_io_down_a_payload_address;
  wire       [2:0]    toTileink_io_down_a_payload_size;
  wire       [3:0]    toTileink_io_down_a_payload_mask;
  wire       [31:0]   toTileink_io_down_a_payload_data;
  wire                toTileink_io_down_a_payload_corrupt;
  wire                toTileink_io_down_d_ready;
  wire                io_up_aw_combStage_valid;
  wire                io_up_aw_combStage_ready;
  wire       [31:0]   io_up_aw_combStage_payload_addr;
  wire       [3:0]    io_up_aw_combStage_payload_id;
  wire       [3:0]    io_up_aw_combStage_payload_region;
  wire       [7:0]    io_up_aw_combStage_payload_len;
  wire       [2:0]    io_up_aw_combStage_payload_size;
  wire       [1:0]    io_up_aw_combStage_payload_burst;
  wire       [0:0]    io_up_aw_combStage_payload_lock;
  wire       [3:0]    io_up_aw_combStage_payload_cache;
  wire       [3:0]    io_up_aw_combStage_payload_qos;
  wire       [2:0]    io_up_aw_combStage_payload_prot;
  wire                io_up_w_combStage_valid;
  wire                io_up_w_combStage_ready;
  wire       [31:0]   io_up_w_combStage_payload_data;
  wire       [3:0]    io_up_w_combStage_payload_strb;
  wire                io_up_w_combStage_payload_last;
  `ifndef SYNTHESIS
  reg [127:0] io_down_a_payload_opcode_string;
  reg [119:0] io_down_d_payload_opcode_string;
  `endif


  Axi4WriteOnlyOnePerId onePerId (
    .io_up_aw_valid            (io_up_aw_combStage_valid               ), //i
    .io_up_aw_ready            (onePerId_io_up_aw_ready                ), //o
    .io_up_aw_payload_addr     (io_up_aw_combStage_payload_addr[31:0]  ), //i
    .io_up_aw_payload_id       (io_up_aw_combStage_payload_id[3:0]     ), //i
    .io_up_aw_payload_region   (io_up_aw_combStage_payload_region[3:0] ), //i
    .io_up_aw_payload_len      (io_up_aw_combStage_payload_len[7:0]    ), //i
    .io_up_aw_payload_size     (io_up_aw_combStage_payload_size[2:0]   ), //i
    .io_up_aw_payload_burst    (io_up_aw_combStage_payload_burst[1:0]  ), //i
    .io_up_aw_payload_lock     (io_up_aw_combStage_payload_lock        ), //i
    .io_up_aw_payload_cache    (io_up_aw_combStage_payload_cache[3:0]  ), //i
    .io_up_aw_payload_qos      (io_up_aw_combStage_payload_qos[3:0]    ), //i
    .io_up_aw_payload_prot     (io_up_aw_combStage_payload_prot[2:0]   ), //i
    .io_up_w_valid             (io_up_w_combStage_valid                ), //i
    .io_up_w_ready             (onePerId_io_up_w_ready                 ), //o
    .io_up_w_payload_data      (io_up_w_combStage_payload_data[31:0]   ), //i
    .io_up_w_payload_strb      (io_up_w_combStage_payload_strb[3:0]    ), //i
    .io_up_w_payload_last      (io_up_w_combStage_payload_last         ), //i
    .io_up_b_valid             (onePerId_io_up_b_valid                 ), //o
    .io_up_b_ready             (io_up_b_ready                          ), //i
    .io_up_b_payload_id        (onePerId_io_up_b_payload_id[3:0]       ), //o
    .io_up_b_payload_resp      (onePerId_io_up_b_payload_resp[1:0]     ), //o
    .io_down_aw_valid          (onePerId_io_down_aw_valid              ), //o
    .io_down_aw_ready          (compactor_io_up_aw_ready               ), //i
    .io_down_aw_payload_addr   (onePerId_io_down_aw_payload_addr[31:0] ), //o
    .io_down_aw_payload_id     (onePerId_io_down_aw_payload_id[3:0]    ), //o
    .io_down_aw_payload_region (onePerId_io_down_aw_payload_region[3:0]), //o
    .io_down_aw_payload_len    (onePerId_io_down_aw_payload_len[7:0]   ), //o
    .io_down_aw_payload_size   (onePerId_io_down_aw_payload_size[2:0]  ), //o
    .io_down_aw_payload_burst  (onePerId_io_down_aw_payload_burst[1:0] ), //o
    .io_down_aw_payload_lock   (onePerId_io_down_aw_payload_lock       ), //o
    .io_down_aw_payload_cache  (onePerId_io_down_aw_payload_cache[3:0] ), //o
    .io_down_aw_payload_qos    (onePerId_io_down_aw_payload_qos[3:0]   ), //o
    .io_down_aw_payload_prot   (onePerId_io_down_aw_payload_prot[2:0]  ), //o
    .io_down_w_valid           (onePerId_io_down_w_valid               ), //o
    .io_down_w_ready           (compactor_io_up_w_ready                ), //i
    .io_down_w_payload_data    (onePerId_io_down_w_payload_data[31:0]  ), //o
    .io_down_w_payload_strb    (onePerId_io_down_w_payload_strb[3:0]   ), //o
    .io_down_w_payload_last    (onePerId_io_down_w_payload_last        ), //o
    .io_down_b_valid           (compactor_io_up_b_valid                ), //i
    .io_down_b_ready           (onePerId_io_down_b_ready               ), //o
    .io_down_b_payload_id      (compactor_io_up_b_payload_id[3:0]      ), //i
    .io_down_b_payload_resp    (compactor_io_up_b_payload_resp[1:0]    ), //i
    .clk                       (clk                                    ), //i
    .reset                     (reset                                  )  //i
  );
  Axi4WriteOnlyCompactor compactor (
    .io_up_aw_valid            (onePerId_io_down_aw_valid               ), //i
    .io_up_aw_ready            (compactor_io_up_aw_ready                ), //o
    .io_up_aw_payload_addr     (onePerId_io_down_aw_payload_addr[31:0]  ), //i
    .io_up_aw_payload_id       (onePerId_io_down_aw_payload_id[3:0]     ), //i
    .io_up_aw_payload_region   (onePerId_io_down_aw_payload_region[3:0] ), //i
    .io_up_aw_payload_len      (onePerId_io_down_aw_payload_len[7:0]    ), //i
    .io_up_aw_payload_size     (onePerId_io_down_aw_payload_size[2:0]   ), //i
    .io_up_aw_payload_burst    (onePerId_io_down_aw_payload_burst[1:0]  ), //i
    .io_up_aw_payload_lock     (onePerId_io_down_aw_payload_lock        ), //i
    .io_up_aw_payload_cache    (onePerId_io_down_aw_payload_cache[3:0]  ), //i
    .io_up_aw_payload_qos      (onePerId_io_down_aw_payload_qos[3:0]    ), //i
    .io_up_aw_payload_prot     (onePerId_io_down_aw_payload_prot[2:0]   ), //i
    .io_up_w_valid             (onePerId_io_down_w_valid                ), //i
    .io_up_w_ready             (compactor_io_up_w_ready                 ), //o
    .io_up_w_payload_data      (onePerId_io_down_w_payload_data[31:0]   ), //i
    .io_up_w_payload_strb      (onePerId_io_down_w_payload_strb[3:0]    ), //i
    .io_up_w_payload_last      (onePerId_io_down_w_payload_last         ), //i
    .io_up_b_valid             (compactor_io_up_b_valid                 ), //o
    .io_up_b_ready             (onePerId_io_down_b_ready                ), //i
    .io_up_b_payload_id        (compactor_io_up_b_payload_id[3:0]       ), //o
    .io_up_b_payload_resp      (compactor_io_up_b_payload_resp[1:0]     ), //o
    .io_down_aw_valid          (compactor_io_down_aw_valid              ), //o
    .io_down_aw_ready          (aligner_io_up_aw_ready                  ), //i
    .io_down_aw_payload_addr   (compactor_io_down_aw_payload_addr[31:0] ), //o
    .io_down_aw_payload_id     (compactor_io_down_aw_payload_id[3:0]    ), //o
    .io_down_aw_payload_region (compactor_io_down_aw_payload_region[3:0]), //o
    .io_down_aw_payload_len    (compactor_io_down_aw_payload_len[7:0]   ), //o
    .io_down_aw_payload_size   (compactor_io_down_aw_payload_size[2:0]  ), //o
    .io_down_aw_payload_burst  (compactor_io_down_aw_payload_burst[1:0] ), //o
    .io_down_aw_payload_lock   (compactor_io_down_aw_payload_lock       ), //o
    .io_down_aw_payload_cache  (compactor_io_down_aw_payload_cache[3:0] ), //o
    .io_down_aw_payload_qos    (compactor_io_down_aw_payload_qos[3:0]   ), //o
    .io_down_aw_payload_prot   (compactor_io_down_aw_payload_prot[2:0]  ), //o
    .io_down_w_valid           (compactor_io_down_w_valid               ), //o
    .io_down_w_ready           (aligner_io_up_w_ready                   ), //i
    .io_down_w_payload_data    (compactor_io_down_w_payload_data[31:0]  ), //o
    .io_down_w_payload_strb    (compactor_io_down_w_payload_strb[3:0]   ), //o
    .io_down_w_payload_last    (compactor_io_down_w_payload_last        ), //o
    .io_down_b_valid           (aligner_io_up_b_valid                   ), //i
    .io_down_b_ready           (compactor_io_down_b_ready               ), //o
    .io_down_b_payload_id      (aligner_io_up_b_payload_id[3:0]         ), //i
    .io_down_b_payload_resp    (aligner_io_up_b_payload_resp[1:0]       ), //i
    .clk                       (clk                                     ), //i
    .reset                     (reset                                   )  //i
  );
  Axi4WriteOnlyAligner aligner (
    .io_up_aw_valid            (compactor_io_down_aw_valid              ), //i
    .io_up_aw_ready            (aligner_io_up_aw_ready                  ), //o
    .io_up_aw_payload_addr     (compactor_io_down_aw_payload_addr[31:0] ), //i
    .io_up_aw_payload_id       (compactor_io_down_aw_payload_id[3:0]    ), //i
    .io_up_aw_payload_region   (compactor_io_down_aw_payload_region[3:0]), //i
    .io_up_aw_payload_len      (compactor_io_down_aw_payload_len[7:0]   ), //i
    .io_up_aw_payload_size     (compactor_io_down_aw_payload_size[2:0]  ), //i
    .io_up_aw_payload_burst    (compactor_io_down_aw_payload_burst[1:0] ), //i
    .io_up_aw_payload_lock     (compactor_io_down_aw_payload_lock       ), //i
    .io_up_aw_payload_cache    (compactor_io_down_aw_payload_cache[3:0] ), //i
    .io_up_aw_payload_qos      (compactor_io_down_aw_payload_qos[3:0]   ), //i
    .io_up_aw_payload_prot     (compactor_io_down_aw_payload_prot[2:0]  ), //i
    .io_up_w_valid             (compactor_io_down_w_valid               ), //i
    .io_up_w_ready             (aligner_io_up_w_ready                   ), //o
    .io_up_w_payload_data      (compactor_io_down_w_payload_data[31:0]  ), //i
    .io_up_w_payload_strb      (compactor_io_down_w_payload_strb[3:0]   ), //i
    .io_up_w_payload_last      (compactor_io_down_w_payload_last        ), //i
    .io_up_b_valid             (aligner_io_up_b_valid                   ), //o
    .io_up_b_ready             (compactor_io_down_b_ready               ), //i
    .io_up_b_payload_id        (aligner_io_up_b_payload_id[3:0]         ), //o
    .io_up_b_payload_resp      (aligner_io_up_b_payload_resp[1:0]       ), //o
    .io_down_aw_valid          (aligner_io_down_aw_valid                ), //o
    .io_down_aw_ready          (toTileink_io_up_aw_ready                ), //i
    .io_down_aw_payload_addr   (aligner_io_down_aw_payload_addr[31:0]   ), //o
    .io_down_aw_payload_id     (aligner_io_down_aw_payload_id[1:0]      ), //o
    .io_down_aw_payload_region (aligner_io_down_aw_payload_region[3:0]  ), //o
    .io_down_aw_payload_len    (aligner_io_down_aw_payload_len[7:0]     ), //o
    .io_down_aw_payload_size   (aligner_io_down_aw_payload_size[2:0]    ), //o
    .io_down_aw_payload_burst  (aligner_io_down_aw_payload_burst[1:0]   ), //o
    .io_down_aw_payload_lock   (aligner_io_down_aw_payload_lock         ), //o
    .io_down_aw_payload_cache  (aligner_io_down_aw_payload_cache[3:0]   ), //o
    .io_down_aw_payload_qos    (aligner_io_down_aw_payload_qos[3:0]     ), //o
    .io_down_aw_payload_prot   (aligner_io_down_aw_payload_prot[2:0]    ), //o
    .io_down_w_valid           (aligner_io_down_w_valid                 ), //o
    .io_down_w_ready           (toTileink_io_up_w_ready                 ), //i
    .io_down_w_payload_data    (aligner_io_down_w_payload_data[31:0]    ), //o
    .io_down_w_payload_strb    (aligner_io_down_w_payload_strb[3:0]     ), //o
    .io_down_w_payload_last    (aligner_io_down_w_payload_last          ), //o
    .io_down_b_valid           (toTileink_io_up_b_valid                 ), //i
    .io_down_b_ready           (aligner_io_down_b_ready                 ), //o
    .io_down_b_payload_id      (toTileink_io_up_b_payload_id[1:0]       ), //i
    .io_down_b_payload_resp    (toTileink_io_up_b_payload_resp[1:0]     ), //i
    .clk                       (clk                                     ), //i
    .reset                     (reset                                   )  //i
  );
  Axi4WriteOnlyToTilelink toTileink (
    .io_up_aw_valid            (aligner_io_down_aw_valid                 ), //i
    .io_up_aw_ready            (toTileink_io_up_aw_ready                 ), //o
    .io_up_aw_payload_addr     (aligner_io_down_aw_payload_addr[31:0]    ), //i
    .io_up_aw_payload_id       (aligner_io_down_aw_payload_id[1:0]       ), //i
    .io_up_aw_payload_region   (aligner_io_down_aw_payload_region[3:0]   ), //i
    .io_up_aw_payload_len      (aligner_io_down_aw_payload_len[7:0]      ), //i
    .io_up_aw_payload_size     (aligner_io_down_aw_payload_size[2:0]     ), //i
    .io_up_aw_payload_burst    (aligner_io_down_aw_payload_burst[1:0]    ), //i
    .io_up_aw_payload_lock     (aligner_io_down_aw_payload_lock          ), //i
    .io_up_aw_payload_cache    (aligner_io_down_aw_payload_cache[3:0]    ), //i
    .io_up_aw_payload_qos      (aligner_io_down_aw_payload_qos[3:0]      ), //i
    .io_up_aw_payload_prot     (aligner_io_down_aw_payload_prot[2:0]     ), //i
    .io_up_w_valid             (aligner_io_down_w_valid                  ), //i
    .io_up_w_ready             (toTileink_io_up_w_ready                  ), //o
    .io_up_w_payload_data      (aligner_io_down_w_payload_data[31:0]     ), //i
    .io_up_w_payload_strb      (aligner_io_down_w_payload_strb[3:0]      ), //i
    .io_up_w_payload_last      (aligner_io_down_w_payload_last           ), //i
    .io_up_b_valid             (toTileink_io_up_b_valid                  ), //o
    .io_up_b_ready             (aligner_io_down_b_ready                  ), //i
    .io_up_b_payload_id        (toTileink_io_up_b_payload_id[1:0]        ), //o
    .io_up_b_payload_resp      (toTileink_io_up_b_payload_resp[1:0]      ), //o
    .io_down_a_valid           (toTileink_io_down_a_valid                ), //o
    .io_down_a_ready           (io_down_a_ready                          ), //i
    .io_down_a_payload_opcode  (toTileink_io_down_a_payload_opcode[2:0]  ), //o
    .io_down_a_payload_param   (toTileink_io_down_a_payload_param[2:0]   ), //o
    .io_down_a_payload_source  (toTileink_io_down_a_payload_source[1:0]  ), //o
    .io_down_a_payload_address (toTileink_io_down_a_payload_address[31:0]), //o
    .io_down_a_payload_size    (toTileink_io_down_a_payload_size[2:0]    ), //o
    .io_down_a_payload_mask    (toTileink_io_down_a_payload_mask[3:0]    ), //o
    .io_down_a_payload_data    (toTileink_io_down_a_payload_data[31:0]   ), //o
    .io_down_a_payload_corrupt (toTileink_io_down_a_payload_corrupt      ), //o
    .io_down_d_valid           (io_down_d_valid                          ), //i
    .io_down_d_ready           (toTileink_io_down_d_ready                ), //o
    .io_down_d_payload_opcode  (io_down_d_payload_opcode[2:0]            ), //i
    .io_down_d_payload_param   (io_down_d_payload_param[2:0]             ), //i
    .io_down_d_payload_source  (io_down_d_payload_source[1:0]            ), //i
    .io_down_d_payload_size    (io_down_d_payload_size[2:0]              ), //i
    .io_down_d_payload_denied  (io_down_d_payload_denied                 ), //i
    .clk                       (clk                                      ), //i
    .reset                     (reset                                    )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_down_a_payload_opcode)
      A_PUT_FULL_DATA : io_down_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_down_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_down_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_down_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_down_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_down_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_down_d_payload_opcode)
      D_ACCESS_ACK : io_down_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : io_down_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : io_down_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : io_down_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : io_down_d_payload_opcode_string = "RELEASE_ACK    ";
      default : io_down_d_payload_opcode_string = "???????????????";
    endcase
  end
  `endif

  assign io_up_aw_combStage_valid = io_up_aw_valid;
  assign io_up_aw_ready = io_up_aw_combStage_ready;
  assign io_up_aw_combStage_payload_addr = io_up_aw_payload_addr;
  assign io_up_aw_combStage_payload_id = io_up_aw_payload_id;
  assign io_up_aw_combStage_payload_region = io_up_aw_payload_region;
  assign io_up_aw_combStage_payload_len = io_up_aw_payload_len;
  assign io_up_aw_combStage_payload_size = io_up_aw_payload_size;
  assign io_up_aw_combStage_payload_burst = io_up_aw_payload_burst;
  assign io_up_aw_combStage_payload_lock = io_up_aw_payload_lock;
  assign io_up_aw_combStage_payload_cache = io_up_aw_payload_cache;
  assign io_up_aw_combStage_payload_qos = io_up_aw_payload_qos;
  assign io_up_aw_combStage_payload_prot = io_up_aw_payload_prot;
  assign io_up_aw_combStage_ready = onePerId_io_up_aw_ready;
  assign io_up_w_combStage_valid = io_up_w_valid;
  assign io_up_w_ready = io_up_w_combStage_ready;
  assign io_up_w_combStage_payload_data = io_up_w_payload_data;
  assign io_up_w_combStage_payload_strb = io_up_w_payload_strb;
  assign io_up_w_combStage_payload_last = io_up_w_payload_last;
  assign io_up_w_combStage_ready = onePerId_io_up_w_ready;
  assign io_up_b_valid = onePerId_io_up_b_valid;
  assign io_up_b_payload_id = onePerId_io_up_b_payload_id;
  assign io_up_b_payload_resp = onePerId_io_up_b_payload_resp;
  assign io_down_a_valid = toTileink_io_down_a_valid;
  assign io_down_a_payload_opcode = toTileink_io_down_a_payload_opcode;
  assign io_down_a_payload_param = toTileink_io_down_a_payload_param;
  assign io_down_a_payload_source = toTileink_io_down_a_payload_source;
  assign io_down_a_payload_address = toTileink_io_down_a_payload_address;
  assign io_down_a_payload_size = toTileink_io_down_a_payload_size;
  assign io_down_a_payload_mask = toTileink_io_down_a_payload_mask;
  assign io_down_a_payload_data = toTileink_io_down_a_payload_data;
  assign io_down_a_payload_corrupt = toTileink_io_down_a_payload_corrupt;
  assign io_down_d_ready = toTileink_io_down_d_ready;

endmodule

module Axi4ReadOnlyToTilelinkFull (
  input  wire          io_up_ar_valid,
  output wire          io_up_ar_ready,
  input  wire [31:0]   io_up_ar_payload_addr,
  input  wire [3:0]    io_up_ar_payload_id,
  input  wire [3:0]    io_up_ar_payload_region,
  input  wire [7:0]    io_up_ar_payload_len,
  input  wire [2:0]    io_up_ar_payload_size,
  input  wire [1:0]    io_up_ar_payload_burst,
  input  wire [0:0]    io_up_ar_payload_lock,
  input  wire [3:0]    io_up_ar_payload_cache,
  input  wire [3:0]    io_up_ar_payload_qos,
  input  wire [2:0]    io_up_ar_payload_prot,
  output wire          io_up_r_valid,
  input  wire          io_up_r_ready,
  output wire [31:0]   io_up_r_payload_data,
  output wire [3:0]    io_up_r_payload_id,
  output wire [1:0]    io_up_r_payload_resp,
  output wire          io_up_r_payload_last,
  output wire          io_down_a_valid,
  input  wire          io_down_a_ready,
  output wire [2:0]    io_down_a_payload_opcode,
  output wire [2:0]    io_down_a_payload_param,
  output wire [1:0]    io_down_a_payload_source,
  output wire [31:0]   io_down_a_payload_address,
  output wire [2:0]    io_down_a_payload_size,
  input  wire          io_down_d_valid,
  output wire          io_down_d_ready,
  input  wire [2:0]    io_down_d_payload_opcode,
  input  wire [2:0]    io_down_d_payload_param,
  input  wire [1:0]    io_down_d_payload_source,
  input  wire [2:0]    io_down_d_payload_size,
  input  wire          io_down_d_payload_denied,
  input  wire [31:0]   io_down_d_payload_data,
  input  wire          io_down_d_payload_corrupt,
  input  wire          clk,
  input  wire          reset
);
  localparam A_PUT_FULL_DATA = 3'd0;
  localparam A_PUT_PARTIAL_DATA = 3'd1;
  localparam A_GET = 3'd4;
  localparam A_ACQUIRE_BLOCK = 3'd6;
  localparam A_ACQUIRE_PERM = 3'd7;
  localparam D_ACCESS_ACK = 3'd0;
  localparam D_ACCESS_ACK_DATA = 3'd1;
  localparam D_GRANT = 3'd4;
  localparam D_GRANT_DATA = 3'd5;
  localparam D_RELEASE_ACK = 3'd6;

  wire                onePerId_io_up_ar_ready;
  wire                onePerId_io_up_r_valid;
  wire       [31:0]   onePerId_io_up_r_payload_data;
  wire       [3:0]    onePerId_io_up_r_payload_id;
  wire       [1:0]    onePerId_io_up_r_payload_resp;
  wire                onePerId_io_up_r_payload_last;
  wire                onePerId_io_down_ar_valid;
  wire       [31:0]   onePerId_io_down_ar_payload_addr;
  wire       [3:0]    onePerId_io_down_ar_payload_id;
  wire       [3:0]    onePerId_io_down_ar_payload_region;
  wire       [7:0]    onePerId_io_down_ar_payload_len;
  wire       [2:0]    onePerId_io_down_ar_payload_size;
  wire       [1:0]    onePerId_io_down_ar_payload_burst;
  wire       [0:0]    onePerId_io_down_ar_payload_lock;
  wire       [3:0]    onePerId_io_down_ar_payload_cache;
  wire       [3:0]    onePerId_io_down_ar_payload_qos;
  wire       [2:0]    onePerId_io_down_ar_payload_prot;
  wire                onePerId_io_down_r_ready;
  wire                compactor_io_up_ar_ready;
  wire                compactor_io_up_r_valid;
  wire       [31:0]   compactor_io_up_r_payload_data;
  wire       [3:0]    compactor_io_up_r_payload_id;
  wire       [1:0]    compactor_io_up_r_payload_resp;
  wire                compactor_io_up_r_payload_last;
  wire                compactor_io_down_ar_valid;
  wire       [31:0]   compactor_io_down_ar_payload_addr;
  wire       [3:0]    compactor_io_down_ar_payload_id;
  wire       [3:0]    compactor_io_down_ar_payload_region;
  wire       [7:0]    compactor_io_down_ar_payload_len;
  wire       [2:0]    compactor_io_down_ar_payload_size;
  wire       [1:0]    compactor_io_down_ar_payload_burst;
  wire       [0:0]    compactor_io_down_ar_payload_lock;
  wire       [3:0]    compactor_io_down_ar_payload_cache;
  wire       [3:0]    compactor_io_down_ar_payload_qos;
  wire       [2:0]    compactor_io_down_ar_payload_prot;
  wire                compactor_io_down_r_ready;
  wire                aligner_io_up_ar_ready;
  wire                aligner_io_up_r_valid;
  wire       [31:0]   aligner_io_up_r_payload_data;
  wire       [3:0]    aligner_io_up_r_payload_id;
  wire       [1:0]    aligner_io_up_r_payload_resp;
  wire                aligner_io_up_r_payload_last;
  wire                aligner_io_down_ar_valid;
  wire       [31:0]   aligner_io_down_ar_payload_addr;
  wire       [1:0]    aligner_io_down_ar_payload_id;
  wire       [3:0]    aligner_io_down_ar_payload_region;
  wire       [7:0]    aligner_io_down_ar_payload_len;
  wire       [2:0]    aligner_io_down_ar_payload_size;
  wire       [1:0]    aligner_io_down_ar_payload_burst;
  wire       [0:0]    aligner_io_down_ar_payload_lock;
  wire       [3:0]    aligner_io_down_ar_payload_cache;
  wire       [3:0]    aligner_io_down_ar_payload_qos;
  wire       [2:0]    aligner_io_down_ar_payload_prot;
  wire                aligner_io_down_r_ready;
  wire                toTileink_io_up_ar_ready;
  wire                toTileink_io_up_r_valid;
  wire       [31:0]   toTileink_io_up_r_payload_data;
  wire       [1:0]    toTileink_io_up_r_payload_id;
  wire       [1:0]    toTileink_io_up_r_payload_resp;
  wire                toTileink_io_up_r_payload_last;
  wire                toTileink_io_down_a_valid;
  wire       [2:0]    toTileink_io_down_a_payload_opcode;
  wire       [2:0]    toTileink_io_down_a_payload_param;
  wire       [1:0]    toTileink_io_down_a_payload_source;
  wire       [31:0]   toTileink_io_down_a_payload_address;
  wire       [2:0]    toTileink_io_down_a_payload_size;
  wire                toTileink_io_down_d_ready;
  wire                io_up_ar_combStage_valid;
  wire                io_up_ar_combStage_ready;
  wire       [31:0]   io_up_ar_combStage_payload_addr;
  wire       [3:0]    io_up_ar_combStage_payload_id;
  wire       [3:0]    io_up_ar_combStage_payload_region;
  wire       [7:0]    io_up_ar_combStage_payload_len;
  wire       [2:0]    io_up_ar_combStage_payload_size;
  wire       [1:0]    io_up_ar_combStage_payload_burst;
  wire       [0:0]    io_up_ar_combStage_payload_lock;
  wire       [3:0]    io_up_ar_combStage_payload_cache;
  wire       [3:0]    io_up_ar_combStage_payload_qos;
  wire       [2:0]    io_up_ar_combStage_payload_prot;
  `ifndef SYNTHESIS
  reg [127:0] io_down_a_payload_opcode_string;
  reg [119:0] io_down_d_payload_opcode_string;
  `endif


  Axi4ReadOnlyOnePerId onePerId (
    .io_up_ar_valid            (io_up_ar_combStage_valid               ), //i
    .io_up_ar_ready            (onePerId_io_up_ar_ready                ), //o
    .io_up_ar_payload_addr     (io_up_ar_combStage_payload_addr[31:0]  ), //i
    .io_up_ar_payload_id       (io_up_ar_combStage_payload_id[3:0]     ), //i
    .io_up_ar_payload_region   (io_up_ar_combStage_payload_region[3:0] ), //i
    .io_up_ar_payload_len      (io_up_ar_combStage_payload_len[7:0]    ), //i
    .io_up_ar_payload_size     (io_up_ar_combStage_payload_size[2:0]   ), //i
    .io_up_ar_payload_burst    (io_up_ar_combStage_payload_burst[1:0]  ), //i
    .io_up_ar_payload_lock     (io_up_ar_combStage_payload_lock        ), //i
    .io_up_ar_payload_cache    (io_up_ar_combStage_payload_cache[3:0]  ), //i
    .io_up_ar_payload_qos      (io_up_ar_combStage_payload_qos[3:0]    ), //i
    .io_up_ar_payload_prot     (io_up_ar_combStage_payload_prot[2:0]   ), //i
    .io_up_r_valid             (onePerId_io_up_r_valid                 ), //o
    .io_up_r_ready             (io_up_r_ready                          ), //i
    .io_up_r_payload_data      (onePerId_io_up_r_payload_data[31:0]    ), //o
    .io_up_r_payload_id        (onePerId_io_up_r_payload_id[3:0]       ), //o
    .io_up_r_payload_resp      (onePerId_io_up_r_payload_resp[1:0]     ), //o
    .io_up_r_payload_last      (onePerId_io_up_r_payload_last          ), //o
    .io_down_ar_valid          (onePerId_io_down_ar_valid              ), //o
    .io_down_ar_ready          (compactor_io_up_ar_ready               ), //i
    .io_down_ar_payload_addr   (onePerId_io_down_ar_payload_addr[31:0] ), //o
    .io_down_ar_payload_id     (onePerId_io_down_ar_payload_id[3:0]    ), //o
    .io_down_ar_payload_region (onePerId_io_down_ar_payload_region[3:0]), //o
    .io_down_ar_payload_len    (onePerId_io_down_ar_payload_len[7:0]   ), //o
    .io_down_ar_payload_size   (onePerId_io_down_ar_payload_size[2:0]  ), //o
    .io_down_ar_payload_burst  (onePerId_io_down_ar_payload_burst[1:0] ), //o
    .io_down_ar_payload_lock   (onePerId_io_down_ar_payload_lock       ), //o
    .io_down_ar_payload_cache  (onePerId_io_down_ar_payload_cache[3:0] ), //o
    .io_down_ar_payload_qos    (onePerId_io_down_ar_payload_qos[3:0]   ), //o
    .io_down_ar_payload_prot   (onePerId_io_down_ar_payload_prot[2:0]  ), //o
    .io_down_r_valid           (compactor_io_up_r_valid                ), //i
    .io_down_r_ready           (onePerId_io_down_r_ready               ), //o
    .io_down_r_payload_data    (compactor_io_up_r_payload_data[31:0]   ), //i
    .io_down_r_payload_id      (compactor_io_up_r_payload_id[3:0]      ), //i
    .io_down_r_payload_resp    (compactor_io_up_r_payload_resp[1:0]    ), //i
    .io_down_r_payload_last    (compactor_io_up_r_payload_last         ), //i
    .clk                       (clk                                    ), //i
    .reset                     (reset                                  )  //i
  );
  Axi4ReadOnlyCompactor compactor (
    .io_up_ar_valid            (onePerId_io_down_ar_valid               ), //i
    .io_up_ar_ready            (compactor_io_up_ar_ready                ), //o
    .io_up_ar_payload_addr     (onePerId_io_down_ar_payload_addr[31:0]  ), //i
    .io_up_ar_payload_id       (onePerId_io_down_ar_payload_id[3:0]     ), //i
    .io_up_ar_payload_region   (onePerId_io_down_ar_payload_region[3:0] ), //i
    .io_up_ar_payload_len      (onePerId_io_down_ar_payload_len[7:0]    ), //i
    .io_up_ar_payload_size     (onePerId_io_down_ar_payload_size[2:0]   ), //i
    .io_up_ar_payload_burst    (onePerId_io_down_ar_payload_burst[1:0]  ), //i
    .io_up_ar_payload_lock     (onePerId_io_down_ar_payload_lock        ), //i
    .io_up_ar_payload_cache    (onePerId_io_down_ar_payload_cache[3:0]  ), //i
    .io_up_ar_payload_qos      (onePerId_io_down_ar_payload_qos[3:0]    ), //i
    .io_up_ar_payload_prot     (onePerId_io_down_ar_payload_prot[2:0]   ), //i
    .io_up_r_valid             (compactor_io_up_r_valid                 ), //o
    .io_up_r_ready             (onePerId_io_down_r_ready                ), //i
    .io_up_r_payload_data      (compactor_io_up_r_payload_data[31:0]    ), //o
    .io_up_r_payload_id        (compactor_io_up_r_payload_id[3:0]       ), //o
    .io_up_r_payload_resp      (compactor_io_up_r_payload_resp[1:0]     ), //o
    .io_up_r_payload_last      (compactor_io_up_r_payload_last          ), //o
    .io_down_ar_valid          (compactor_io_down_ar_valid              ), //o
    .io_down_ar_ready          (aligner_io_up_ar_ready                  ), //i
    .io_down_ar_payload_addr   (compactor_io_down_ar_payload_addr[31:0] ), //o
    .io_down_ar_payload_id     (compactor_io_down_ar_payload_id[3:0]    ), //o
    .io_down_ar_payload_region (compactor_io_down_ar_payload_region[3:0]), //o
    .io_down_ar_payload_len    (compactor_io_down_ar_payload_len[7:0]   ), //o
    .io_down_ar_payload_size   (compactor_io_down_ar_payload_size[2:0]  ), //o
    .io_down_ar_payload_burst  (compactor_io_down_ar_payload_burst[1:0] ), //o
    .io_down_ar_payload_lock   (compactor_io_down_ar_payload_lock       ), //o
    .io_down_ar_payload_cache  (compactor_io_down_ar_payload_cache[3:0] ), //o
    .io_down_ar_payload_qos    (compactor_io_down_ar_payload_qos[3:0]   ), //o
    .io_down_ar_payload_prot   (compactor_io_down_ar_payload_prot[2:0]  ), //o
    .io_down_r_valid           (aligner_io_up_r_valid                   ), //i
    .io_down_r_ready           (compactor_io_down_r_ready               ), //o
    .io_down_r_payload_data    (aligner_io_up_r_payload_data[31:0]      ), //i
    .io_down_r_payload_id      (aligner_io_up_r_payload_id[3:0]         ), //i
    .io_down_r_payload_resp    (aligner_io_up_r_payload_resp[1:0]       ), //i
    .io_down_r_payload_last    (aligner_io_up_r_payload_last            ), //i
    .clk                       (clk                                     ), //i
    .reset                     (reset                                   )  //i
  );
  Axi4ReadOnlyAligner aligner (
    .io_up_ar_valid            (compactor_io_down_ar_valid              ), //i
    .io_up_ar_ready            (aligner_io_up_ar_ready                  ), //o
    .io_up_ar_payload_addr     (compactor_io_down_ar_payload_addr[31:0] ), //i
    .io_up_ar_payload_id       (compactor_io_down_ar_payload_id[3:0]    ), //i
    .io_up_ar_payload_region   (compactor_io_down_ar_payload_region[3:0]), //i
    .io_up_ar_payload_len      (compactor_io_down_ar_payload_len[7:0]   ), //i
    .io_up_ar_payload_size     (compactor_io_down_ar_payload_size[2:0]  ), //i
    .io_up_ar_payload_burst    (compactor_io_down_ar_payload_burst[1:0] ), //i
    .io_up_ar_payload_lock     (compactor_io_down_ar_payload_lock       ), //i
    .io_up_ar_payload_cache    (compactor_io_down_ar_payload_cache[3:0] ), //i
    .io_up_ar_payload_qos      (compactor_io_down_ar_payload_qos[3:0]   ), //i
    .io_up_ar_payload_prot     (compactor_io_down_ar_payload_prot[2:0]  ), //i
    .io_up_r_valid             (aligner_io_up_r_valid                   ), //o
    .io_up_r_ready             (compactor_io_down_r_ready               ), //i
    .io_up_r_payload_data      (aligner_io_up_r_payload_data[31:0]      ), //o
    .io_up_r_payload_id        (aligner_io_up_r_payload_id[3:0]         ), //o
    .io_up_r_payload_resp      (aligner_io_up_r_payload_resp[1:0]       ), //o
    .io_up_r_payload_last      (aligner_io_up_r_payload_last            ), //o
    .io_down_ar_valid          (aligner_io_down_ar_valid                ), //o
    .io_down_ar_ready          (toTileink_io_up_ar_ready                ), //i
    .io_down_ar_payload_addr   (aligner_io_down_ar_payload_addr[31:0]   ), //o
    .io_down_ar_payload_id     (aligner_io_down_ar_payload_id[1:0]      ), //o
    .io_down_ar_payload_region (aligner_io_down_ar_payload_region[3:0]  ), //o
    .io_down_ar_payload_len    (aligner_io_down_ar_payload_len[7:0]     ), //o
    .io_down_ar_payload_size   (aligner_io_down_ar_payload_size[2:0]    ), //o
    .io_down_ar_payload_burst  (aligner_io_down_ar_payload_burst[1:0]   ), //o
    .io_down_ar_payload_lock   (aligner_io_down_ar_payload_lock         ), //o
    .io_down_ar_payload_cache  (aligner_io_down_ar_payload_cache[3:0]   ), //o
    .io_down_ar_payload_qos    (aligner_io_down_ar_payload_qos[3:0]     ), //o
    .io_down_ar_payload_prot   (aligner_io_down_ar_payload_prot[2:0]    ), //o
    .io_down_r_valid           (toTileink_io_up_r_valid                 ), //i
    .io_down_r_ready           (aligner_io_down_r_ready                 ), //o
    .io_down_r_payload_data    (toTileink_io_up_r_payload_data[31:0]    ), //i
    .io_down_r_payload_id      (toTileink_io_up_r_payload_id[1:0]       ), //i
    .io_down_r_payload_resp    (toTileink_io_up_r_payload_resp[1:0]     ), //i
    .io_down_r_payload_last    (toTileink_io_up_r_payload_last          ), //i
    .clk                       (clk                                     ), //i
    .reset                     (reset                                   )  //i
  );
  Axi4ReadOnlyToTilelink toTileink (
    .io_up_ar_valid            (aligner_io_down_ar_valid                 ), //i
    .io_up_ar_ready            (toTileink_io_up_ar_ready                 ), //o
    .io_up_ar_payload_addr     (aligner_io_down_ar_payload_addr[31:0]    ), //i
    .io_up_ar_payload_id       (aligner_io_down_ar_payload_id[1:0]       ), //i
    .io_up_ar_payload_region   (aligner_io_down_ar_payload_region[3:0]   ), //i
    .io_up_ar_payload_len      (aligner_io_down_ar_payload_len[7:0]      ), //i
    .io_up_ar_payload_size     (aligner_io_down_ar_payload_size[2:0]     ), //i
    .io_up_ar_payload_burst    (aligner_io_down_ar_payload_burst[1:0]    ), //i
    .io_up_ar_payload_lock     (aligner_io_down_ar_payload_lock          ), //i
    .io_up_ar_payload_cache    (aligner_io_down_ar_payload_cache[3:0]    ), //i
    .io_up_ar_payload_qos      (aligner_io_down_ar_payload_qos[3:0]      ), //i
    .io_up_ar_payload_prot     (aligner_io_down_ar_payload_prot[2:0]     ), //i
    .io_up_r_valid             (toTileink_io_up_r_valid                  ), //o
    .io_up_r_ready             (aligner_io_down_r_ready                  ), //i
    .io_up_r_payload_data      (toTileink_io_up_r_payload_data[31:0]     ), //o
    .io_up_r_payload_id        (toTileink_io_up_r_payload_id[1:0]        ), //o
    .io_up_r_payload_resp      (toTileink_io_up_r_payload_resp[1:0]      ), //o
    .io_up_r_payload_last      (toTileink_io_up_r_payload_last           ), //o
    .io_down_a_valid           (toTileink_io_down_a_valid                ), //o
    .io_down_a_ready           (io_down_a_ready                          ), //i
    .io_down_a_payload_opcode  (toTileink_io_down_a_payload_opcode[2:0]  ), //o
    .io_down_a_payload_param   (toTileink_io_down_a_payload_param[2:0]   ), //o
    .io_down_a_payload_source  (toTileink_io_down_a_payload_source[1:0]  ), //o
    .io_down_a_payload_address (toTileink_io_down_a_payload_address[31:0]), //o
    .io_down_a_payload_size    (toTileink_io_down_a_payload_size[2:0]    ), //o
    .io_down_d_valid           (io_down_d_valid                          ), //i
    .io_down_d_ready           (toTileink_io_down_d_ready                ), //o
    .io_down_d_payload_opcode  (io_down_d_payload_opcode[2:0]            ), //i
    .io_down_d_payload_param   (io_down_d_payload_param[2:0]             ), //i
    .io_down_d_payload_source  (io_down_d_payload_source[1:0]            ), //i
    .io_down_d_payload_size    (io_down_d_payload_size[2:0]              ), //i
    .io_down_d_payload_denied  (io_down_d_payload_denied                 ), //i
    .io_down_d_payload_data    (io_down_d_payload_data[31:0]             ), //i
    .io_down_d_payload_corrupt (io_down_d_payload_corrupt                ), //i
    .clk                       (clk                                      ), //i
    .reset                     (reset                                    )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_down_a_payload_opcode)
      A_PUT_FULL_DATA : io_down_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_down_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_down_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_down_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_down_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_down_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_down_d_payload_opcode)
      D_ACCESS_ACK : io_down_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : io_down_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : io_down_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : io_down_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : io_down_d_payload_opcode_string = "RELEASE_ACK    ";
      default : io_down_d_payload_opcode_string = "???????????????";
    endcase
  end
  `endif

  assign io_up_ar_combStage_valid = io_up_ar_valid;
  assign io_up_ar_ready = io_up_ar_combStage_ready;
  assign io_up_ar_combStage_payload_addr = io_up_ar_payload_addr;
  assign io_up_ar_combStage_payload_id = io_up_ar_payload_id;
  assign io_up_ar_combStage_payload_region = io_up_ar_payload_region;
  assign io_up_ar_combStage_payload_len = io_up_ar_payload_len;
  assign io_up_ar_combStage_payload_size = io_up_ar_payload_size;
  assign io_up_ar_combStage_payload_burst = io_up_ar_payload_burst;
  assign io_up_ar_combStage_payload_lock = io_up_ar_payload_lock;
  assign io_up_ar_combStage_payload_cache = io_up_ar_payload_cache;
  assign io_up_ar_combStage_payload_qos = io_up_ar_payload_qos;
  assign io_up_ar_combStage_payload_prot = io_up_ar_payload_prot;
  assign io_up_ar_combStage_ready = onePerId_io_up_ar_ready;
  assign io_up_r_valid = onePerId_io_up_r_valid;
  assign io_up_r_payload_data = onePerId_io_up_r_payload_data;
  assign io_up_r_payload_id = onePerId_io_up_r_payload_id;
  assign io_up_r_payload_resp = onePerId_io_up_r_payload_resp;
  assign io_up_r_payload_last = onePerId_io_up_r_payload_last;
  assign io_down_a_valid = toTileink_io_down_a_valid;
  assign io_down_a_payload_opcode = toTileink_io_down_a_payload_opcode;
  assign io_down_a_payload_param = toTileink_io_down_a_payload_param;
  assign io_down_a_payload_source = toTileink_io_down_a_payload_source;
  assign io_down_a_payload_address = toTileink_io_down_a_payload_address;
  assign io_down_a_payload_size = toTileink_io_down_a_payload_size;
  assign io_down_d_ready = toTileink_io_down_d_ready;

endmodule

//ContextAsyncBufferFull_1 replaced by ContextAsyncBufferFull

module ContextAsyncBufferFull (
  input  wire          io_add_valid,
  output wire          io_add_ready,
  input  wire [1:0]    io_add_payload_id,
  input  wire [1:0]    io_add_payload_context,
  input  wire          io_remove_valid,
  input  wire [1:0]    io_remove_payload_id,
  input  wire [1:0]    io_query_id,
  output wire [1:0]    io_query_context,
  input  wire          clk,
  input  wire          reset
);

  wire       [1:0]    contexts_spinal_port1;
  wire       [1:0]    _zz_contexts_port;
  reg                 _zz_1;
  wire                write_valid;
  wire       [1:0]    write_payload_address;
  wire       [1:0]    write_payload_data;
  wire       [1:0]    read_address;
  wire       [1:0]    read_data;
  (* ram_style = "distributed" *) reg [1:0] contexts [0:3];

  assign _zz_contexts_port = write_payload_data;
  always @(posedge clk) begin
    if(_zz_1) begin
      contexts[write_payload_address] <= _zz_contexts_port;
    end
  end

  assign contexts_spinal_port1 = contexts[read_address];
  always @(*) begin
    _zz_1 = 1'b0;
    if(write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign write_valid = io_add_valid;
  assign write_payload_address = io_add_payload_id;
  assign write_payload_data = io_add_payload_context;
  assign io_add_ready = 1'b1;
  assign read_data = contexts_spinal_port1;
  assign read_address = io_query_id;
  assign io_query_context = read_data;

endmodule

module StreamArbiter (
  input  wire          io_inputs_0_valid,
  output wire          io_inputs_0_ready,
  input  wire [2:0]    io_inputs_0_payload_opcode,
  input  wire [2:0]    io_inputs_0_payload_param,
  input  wire [2:0]    io_inputs_0_payload_source,
  input  wire [13:0]   io_inputs_0_payload_address,
  input  wire [2:0]    io_inputs_0_payload_size,
  input  wire [15:0]   io_inputs_0_payload_mask,
  input  wire [127:0]  io_inputs_0_payload_data,
  input  wire          io_inputs_0_payload_corrupt,
  input  wire          io_inputs_1_valid,
  output wire          io_inputs_1_ready,
  input  wire [2:0]    io_inputs_1_payload_opcode,
  input  wire [2:0]    io_inputs_1_payload_param,
  input  wire [2:0]    io_inputs_1_payload_source,
  input  wire [13:0]   io_inputs_1_payload_address,
  input  wire [2:0]    io_inputs_1_payload_size,
  input  wire [15:0]   io_inputs_1_payload_mask,
  input  wire [127:0]  io_inputs_1_payload_data,
  input  wire          io_inputs_1_payload_corrupt,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire [2:0]    io_output_payload_opcode,
  output wire [2:0]    io_output_payload_param,
  output wire [2:0]    io_output_payload_source,
  output wire [13:0]   io_output_payload_address,
  output wire [2:0]    io_output_payload_size,
  output wire [15:0]   io_output_payload_mask,
  output wire [127:0]  io_output_payload_data,
  output wire          io_output_payload_corrupt,
  output wire [0:0]    io_chosen,
  output wire [1:0]    io_chosenOH,
  input  wire          clk,
  input  wire          reset
);
  localparam A_PUT_FULL_DATA = 3'd0;
  localparam A_PUT_PARTIAL_DATA = 3'd1;
  localparam A_GET = 3'd4;
  localparam A_ACQUIRE_BLOCK = 3'd6;
  localparam A_ACQUIRE_PERM = 3'd7;

  wire       [3:0]    _zz__zz_maskProposal_0_2;
  wire       [3:0]    _zz__zz_maskProposal_0_2_1;
  wire       [1:0]    _zz__zz_maskProposal_0_2_2;
  reg        [0:0]    _zz_io_output_tracker_last;
  reg                 locked;
  wire                maskProposal_0;
  wire                maskProposal_1;
  reg                 maskLocked_0;
  reg                 maskLocked_1;
  wire                maskRouted_0;
  wire                maskRouted_1;
  wire       [1:0]    _zz_maskProposal_0;
  wire       [3:0]    _zz_maskProposal_0_1;
  wire       [3:0]    _zz_maskProposal_0_2;
  wire       [1:0]    _zz_maskProposal_0_3;
  wire                io_output_fire;
  reg        [0:0]    io_output_tracker_beat;
  wire                io_output_tracker_last;
  wire                when_Stream_l794;
  wire       [2:0]    _zz_io_output_payload_opcode;
  wire                _zz_io_chosen;
  `ifndef SYNTHESIS
  reg [127:0] io_inputs_0_payload_opcode_string;
  reg [127:0] io_inputs_1_payload_opcode_string;
  reg [127:0] io_output_payload_opcode_string;
  reg [127:0] _zz_io_output_payload_opcode_string;
  `endif


  assign _zz__zz_maskProposal_0_2 = (_zz_maskProposal_0_1 - _zz__zz_maskProposal_0_2_1);
  assign _zz__zz_maskProposal_0_2_2 = {maskLocked_0,maskLocked_1};
  assign _zz__zz_maskProposal_0_2_1 = {2'd0, _zz__zz_maskProposal_0_2_2};
  always @(*) begin
    case(io_output_payload_size)
      3'b000 : _zz_io_output_tracker_last = 1'b0;
      3'b001 : _zz_io_output_tracker_last = 1'b0;
      3'b010 : _zz_io_output_tracker_last = 1'b0;
      3'b011 : _zz_io_output_tracker_last = 1'b0;
      3'b100 : _zz_io_output_tracker_last = 1'b0;
      default : _zz_io_output_tracker_last = 1'b1;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_inputs_0_payload_opcode)
      A_PUT_FULL_DATA : io_inputs_0_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_inputs_0_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_inputs_0_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_inputs_0_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_inputs_0_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_inputs_0_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_inputs_1_payload_opcode)
      A_PUT_FULL_DATA : io_inputs_1_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_inputs_1_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_inputs_1_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_inputs_1_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_inputs_1_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_inputs_1_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_output_payload_opcode)
      A_PUT_FULL_DATA : io_output_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_output_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_output_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_output_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_output_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_output_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(_zz_io_output_payload_opcode)
      A_PUT_FULL_DATA : _zz_io_output_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : _zz_io_output_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : _zz_io_output_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : _zz_io_output_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : _zz_io_output_payload_opcode_string = "ACQUIRE_PERM    ";
      default : _zz_io_output_payload_opcode_string = "????????????????";
    endcase
  end
  `endif

  assign maskRouted_0 = (locked ? maskLocked_0 : maskProposal_0);
  assign maskRouted_1 = (locked ? maskLocked_1 : maskProposal_1);
  assign _zz_maskProposal_0 = {io_inputs_1_valid,io_inputs_0_valid};
  assign _zz_maskProposal_0_1 = {_zz_maskProposal_0,_zz_maskProposal_0};
  assign _zz_maskProposal_0_2 = (_zz_maskProposal_0_1 & (~ _zz__zz_maskProposal_0_2));
  assign _zz_maskProposal_0_3 = (_zz_maskProposal_0_2[3 : 2] | _zz_maskProposal_0_2[1 : 0]);
  assign maskProposal_0 = _zz_maskProposal_0_3[0];
  assign maskProposal_1 = _zz_maskProposal_0_3[1];
  assign io_output_fire = (io_output_valid && io_output_ready);
  assign io_output_tracker_last = ((! ((1'b0 || (A_PUT_FULL_DATA == io_output_payload_opcode)) || (A_PUT_PARTIAL_DATA == io_output_payload_opcode))) || (io_output_tracker_beat == _zz_io_output_tracker_last));
  assign when_Stream_l794 = (io_output_fire && io_output_tracker_last);
  assign io_output_valid = ((io_inputs_0_valid && maskRouted_0) || (io_inputs_1_valid && maskRouted_1));
  assign _zz_io_output_payload_opcode = (maskRouted_0 ? io_inputs_0_payload_opcode : io_inputs_1_payload_opcode);
  assign io_output_payload_opcode = _zz_io_output_payload_opcode;
  assign io_output_payload_param = (maskRouted_0 ? io_inputs_0_payload_param : io_inputs_1_payload_param);
  assign io_output_payload_source = (maskRouted_0 ? io_inputs_0_payload_source : io_inputs_1_payload_source);
  assign io_output_payload_address = (maskRouted_0 ? io_inputs_0_payload_address : io_inputs_1_payload_address);
  assign io_output_payload_size = (maskRouted_0 ? io_inputs_0_payload_size : io_inputs_1_payload_size);
  assign io_output_payload_mask = (maskRouted_0 ? io_inputs_0_payload_mask : io_inputs_1_payload_mask);
  assign io_output_payload_data = (maskRouted_0 ? io_inputs_0_payload_data : io_inputs_1_payload_data);
  assign io_output_payload_corrupt = (maskRouted_0 ? io_inputs_0_payload_corrupt : io_inputs_1_payload_corrupt);
  assign io_inputs_0_ready = (maskRouted_0 && io_output_ready);
  assign io_inputs_1_ready = (maskRouted_1 && io_output_ready);
  assign io_chosenOH = {maskRouted_1,maskRouted_0};
  assign _zz_io_chosen = io_chosenOH[1];
  assign io_chosen = _zz_io_chosen;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      locked <= 1'b0;
      maskLocked_0 <= 1'b0;
      maskLocked_1 <= 1'b1;
      io_output_tracker_beat <= 1'b0;
    end else begin
      if(io_output_valid) begin
        maskLocked_0 <= maskRouted_0;
        maskLocked_1 <= maskRouted_1;
      end
      if(io_output_valid) begin
        locked <= 1'b1;
      end
      if(io_output_fire) begin
        io_output_tracker_beat <= (io_output_tracker_beat + 1'b1);
        if(io_output_tracker_last) begin
          io_output_tracker_beat <= 1'b0;
        end
      end
      if(when_Stream_l794) begin
        locked <= 1'b0;
      end
    end
  end


endmodule

module Axi4WriteOnlyToTilelink (
  input  wire          io_up_aw_valid,
  output wire          io_up_aw_ready,
  input  wire [31:0]   io_up_aw_payload_addr,
  input  wire [1:0]    io_up_aw_payload_id,
  input  wire [3:0]    io_up_aw_payload_region,
  input  wire [7:0]    io_up_aw_payload_len,
  input  wire [2:0]    io_up_aw_payload_size,
  input  wire [1:0]    io_up_aw_payload_burst,
  input  wire [0:0]    io_up_aw_payload_lock,
  input  wire [3:0]    io_up_aw_payload_cache,
  input  wire [3:0]    io_up_aw_payload_qos,
  input  wire [2:0]    io_up_aw_payload_prot,
  input  wire          io_up_w_valid,
  output wire          io_up_w_ready,
  input  wire [31:0]   io_up_w_payload_data,
  input  wire [3:0]    io_up_w_payload_strb,
  input  wire          io_up_w_payload_last,
  output wire          io_up_b_valid,
  input  wire          io_up_b_ready,
  output wire [1:0]    io_up_b_payload_id,
  output reg  [1:0]    io_up_b_payload_resp,
  output wire          io_down_a_valid,
  input  wire          io_down_a_ready,
  output wire [2:0]    io_down_a_payload_opcode,
  output wire [2:0]    io_down_a_payload_param,
  output wire [1:0]    io_down_a_payload_source,
  output reg  [31:0]   io_down_a_payload_address,
  output wire [2:0]    io_down_a_payload_size,
  output wire [3:0]    io_down_a_payload_mask,
  output wire [31:0]   io_down_a_payload_data,
  output wire          io_down_a_payload_corrupt,
  input  wire          io_down_d_valid,
  output wire          io_down_d_ready,
  input  wire [2:0]    io_down_d_payload_opcode,
  input  wire [2:0]    io_down_d_payload_param,
  input  wire [1:0]    io_down_d_payload_source,
  input  wire [2:0]    io_down_d_payload_size,
  input  wire          io_down_d_payload_denied,
  input  wire          clk,
  input  wire          reset
);
  localparam A_PUT_FULL_DATA = 3'd0;
  localparam A_PUT_PARTIAL_DATA = 3'd1;
  localparam A_GET = 3'd4;
  localparam A_ACQUIRE_BLOCK = 3'd6;
  localparam A_ACQUIRE_PERM = 3'd7;
  localparam D_ACCESS_ACK = 3'd0;
  localparam D_ACCESS_ACK_DATA = 3'd1;
  localparam D_GRANT = 3'd4;
  localparam D_GRANT_DATA = 3'd5;
  localparam D_RELEASE_ACK = 3'd6;

  wire       [7:0]    _zz__zz_a_lenToSize_2;
  wire       [3:0]    _zz_io_down_a_payload_size;
  wire       [3:0]    _zz_io_down_a_payload_size_1;
  wire                a_valid;
  wire                a_ok;
  reg        [2:0]    a_counter;
  wire                io_up_w_fire;
  wire       [7:0]    _zz_a_lenToSize;
  reg        [7:0]    _zz_a_lenToSize_1;
  wire       [7:0]    _zz_a_lenToSize_2;
  reg        [7:0]    _zz_a_lenToSize_3;
  wire       [8:0]    _zz_a_lenToSize_4;
  wire                _zz_a_lenToSize_5;
  wire                _zz_a_lenToSize_6;
  wire                _zz_a_lenToSize_7;
  wire                _zz_a_lenToSize_8;
  wire                _zz_a_lenToSize_9;
  wire                _zz_a_lenToSize_10;
  wire                _zz_a_lenToSize_11;
  wire                _zz_a_lenToSize_12;
  wire       [3:0]    a_lenToSize;
  `ifndef SYNTHESIS
  reg [127:0] io_down_a_payload_opcode_string;
  reg [119:0] io_down_d_payload_opcode_string;
  `endif


  assign _zz__zz_a_lenToSize_2 = (_zz_a_lenToSize_1 - 8'h01);
  assign _zz_io_down_a_payload_size = (a_lenToSize + _zz_io_down_a_payload_size_1);
  assign _zz_io_down_a_payload_size_1 = {1'd0, io_up_aw_payload_size};
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_down_a_payload_opcode)
      A_PUT_FULL_DATA : io_down_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_down_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_down_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_down_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_down_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_down_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_down_d_payload_opcode)
      D_ACCESS_ACK : io_down_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : io_down_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : io_down_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : io_down_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : io_down_d_payload_opcode_string = "RELEASE_ACK    ";
      default : io_down_d_payload_opcode_string = "???????????????";
    endcase
  end
  `endif

  assign a_valid = (io_up_aw_valid && io_up_w_valid);
  assign a_ok = (a_valid && io_down_a_ready);
  assign io_up_aw_ready = (a_ok && io_up_w_payload_last);
  assign io_up_w_ready = a_ok;
  assign io_down_a_valid = a_valid;
  assign io_up_w_fire = (io_up_w_valid && io_up_w_ready);
  assign _zz_a_lenToSize = io_up_aw_payload_len;
  always @(*) begin
    _zz_a_lenToSize_1[0] = _zz_a_lenToSize[7];
    _zz_a_lenToSize_1[1] = _zz_a_lenToSize[6];
    _zz_a_lenToSize_1[2] = _zz_a_lenToSize[5];
    _zz_a_lenToSize_1[3] = _zz_a_lenToSize[4];
    _zz_a_lenToSize_1[4] = _zz_a_lenToSize[3];
    _zz_a_lenToSize_1[5] = _zz_a_lenToSize[2];
    _zz_a_lenToSize_1[6] = _zz_a_lenToSize[1];
    _zz_a_lenToSize_1[7] = _zz_a_lenToSize[0];
  end

  assign _zz_a_lenToSize_2 = (_zz_a_lenToSize_1 & (~ _zz__zz_a_lenToSize_2));
  always @(*) begin
    _zz_a_lenToSize_3[0] = _zz_a_lenToSize_2[7];
    _zz_a_lenToSize_3[1] = _zz_a_lenToSize_2[6];
    _zz_a_lenToSize_3[2] = _zz_a_lenToSize_2[5];
    _zz_a_lenToSize_3[3] = _zz_a_lenToSize_2[4];
    _zz_a_lenToSize_3[4] = _zz_a_lenToSize_2[3];
    _zz_a_lenToSize_3[5] = _zz_a_lenToSize_2[2];
    _zz_a_lenToSize_3[6] = _zz_a_lenToSize_2[1];
    _zz_a_lenToSize_3[7] = _zz_a_lenToSize_2[0];
  end

  assign _zz_a_lenToSize_4 = {_zz_a_lenToSize_3,1'b0};
  assign _zz_a_lenToSize_5 = _zz_a_lenToSize_4[3];
  assign _zz_a_lenToSize_6 = _zz_a_lenToSize_4[5];
  assign _zz_a_lenToSize_7 = _zz_a_lenToSize_4[6];
  assign _zz_a_lenToSize_8 = _zz_a_lenToSize_4[7];
  assign _zz_a_lenToSize_9 = _zz_a_lenToSize_4[8];
  assign _zz_a_lenToSize_10 = (((_zz_a_lenToSize_4[1] || _zz_a_lenToSize_5) || _zz_a_lenToSize_6) || _zz_a_lenToSize_8);
  assign _zz_a_lenToSize_11 = (((_zz_a_lenToSize_4[2] || _zz_a_lenToSize_5) || _zz_a_lenToSize_7) || _zz_a_lenToSize_8);
  assign _zz_a_lenToSize_12 = (((_zz_a_lenToSize_4[4] || _zz_a_lenToSize_6) || _zz_a_lenToSize_7) || _zz_a_lenToSize_8);
  assign a_lenToSize = {_zz_a_lenToSize_9,{_zz_a_lenToSize_12,{_zz_a_lenToSize_11,_zz_a_lenToSize_10}}};
  assign io_down_a_payload_opcode = A_PUT_PARTIAL_DATA;
  assign io_down_a_payload_param = 3'b000;
  assign io_down_a_payload_source = io_up_aw_payload_id;
  always @(*) begin
    io_down_a_payload_address = io_up_aw_payload_addr;
    io_down_a_payload_address[4 : 2] = (io_up_aw_payload_addr[4 : 2] + a_counter);
  end

  assign io_down_a_payload_size = _zz_io_down_a_payload_size[2:0];
  assign io_down_a_payload_mask = io_up_w_payload_strb;
  assign io_down_a_payload_data = io_up_w_payload_data;
  assign io_down_a_payload_corrupt = 1'b0;
  assign io_up_b_valid = io_down_d_valid;
  assign io_down_d_ready = io_up_b_ready;
  assign io_up_b_payload_id = io_down_d_payload_source;
  always @(*) begin
    io_up_b_payload_resp = 2'b00;
    if(io_down_d_payload_denied) begin
      io_up_b_payload_resp = 2'b10;
    end
  end

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      a_counter <= 3'b000;
    end else begin
      if(io_up_w_fire) begin
        a_counter <= (a_counter + 3'b001);
        if(io_up_w_payload_last) begin
          a_counter <= 3'b000;
        end
      end
    end
  end


endmodule

module Axi4WriteOnlyAligner (
  input  wire          io_up_aw_valid,
  output wire          io_up_aw_ready,
  input  wire [31:0]   io_up_aw_payload_addr,
  input  wire [3:0]    io_up_aw_payload_id,
  input  wire [3:0]    io_up_aw_payload_region,
  input  wire [7:0]    io_up_aw_payload_len,
  input  wire [2:0]    io_up_aw_payload_size,
  input  wire [1:0]    io_up_aw_payload_burst,
  input  wire [0:0]    io_up_aw_payload_lock,
  input  wire [3:0]    io_up_aw_payload_cache,
  input  wire [3:0]    io_up_aw_payload_qos,
  input  wire [2:0]    io_up_aw_payload_prot,
  input  wire          io_up_w_valid,
  output reg           io_up_w_ready,
  input  wire [31:0]   io_up_w_payload_data,
  input  wire [3:0]    io_up_w_payload_strb,
  input  wire          io_up_w_payload_last,
  output reg           io_up_b_valid,
  input  wire          io_up_b_ready,
  output wire [3:0]    io_up_b_payload_id,
  output reg  [1:0]    io_up_b_payload_resp,
  output wire          io_down_aw_valid,
  input  wire          io_down_aw_ready,
  output reg  [31:0]   io_down_aw_payload_addr,
  output wire [1:0]    io_down_aw_payload_id,
  output wire [3:0]    io_down_aw_payload_region,
  output wire [7:0]    io_down_aw_payload_len,
  output reg  [2:0]    io_down_aw_payload_size,
  output wire [1:0]    io_down_aw_payload_burst,
  output wire [0:0]    io_down_aw_payload_lock,
  output wire [3:0]    io_down_aw_payload_cache,
  output wire [3:0]    io_down_aw_payload_qos,
  output wire [2:0]    io_down_aw_payload_prot,
  output reg           io_down_w_valid,
  input  wire          io_down_w_ready,
  output wire [31:0]   io_down_w_payload_data,
  output wire [3:0]    io_down_w_payload_strb,
  output wire          io_down_w_payload_last,
  input  wire          io_down_b_valid,
  output wire          io_down_b_ready,
  input  wire [1:0]    io_down_b_payload_id,
  input  wire [1:0]    io_down_b_payload_resp,
  input  wire          clk,
  input  wire          reset
);

  reg        [4:0]    context_mem_spinal_port1;
  wire       [4:0]    _zz_context_mem_port;
  wire       [31:0]   _zz_frontend_split_spliter_boundedEnd;
  wire       [31:0]   _zz_frontend_split_spliter_boundedEnd_1;
  wire       [9:0]    _zz_frontend_split_spliter_boundedEnd_2;
  wire       [4:0]    _zz_frontend_split_aligner_CHUNK_START;
  wire       [4:0]    _zz_frontend_split_aligner_CHUNK_END;
  reg        [1:0]    _zz_frontend_allocateSlot_smallSize;
  wire       [1:0]    _zz_frontend_allocateSlot_smallSize_1;
  wire       [4:0]    _zz_frontend_allocateSlot_wCmd_payload_header;
  wire       [4:0]    _zz_frontend_allocateSlot_wCmd_payload_header_1;
  wire       [2:0]    _zz_downW_header;
  wire       [0:0]    _zz_downW_header_1;
  wire       [2:0]    _zz_downW_ups;
  wire       [0:0]    _zz_downW_ups_1;
  reg                 _zz_upB_handle_done_1;
  wire       [1:0]    _zz_upB_handle_done_2;
  reg                 _zz_upB_handle_error;
  wire       [1:0]    _zz_upB_handle_error_1;
  reg                 upB_handle_ready;
  wire                upB_handle_CTX_last;
  wire       [3:0]    upB_handle_CTX_id;
  wire                upB_fetch_ready;
  wire                frontend_allocateSlot_isThrown;
  wire                frontend_allocateSlot_isFlushed;
  reg        [2:0]    frontend_allocateSlot_split_spliter_CHUNKS_WORDS;
  reg                 frontend_allocateSlot_split_spliter_FIRST;
  wire                frontend_allocateSlot_isRemoved;
  reg        [4:0]    frontend_allocateSlot_split_aligner_CHUNK_END;
  reg        [2:0]    frontend_allocateSlot_split_aligner_LEN;
  reg        [6:0]    frontend_allocateSlot_split_spliter_BOUNDED_BLOCK;
  reg        [4:0]    frontend_allocateSlot_split_aligner_CHUNK_START;
  reg                 frontend_allocateSlot_ready;
  reg        [31:0]   frontend_allocateSlot_bufferize_AW_addr;
  reg        [3:0]    frontend_allocateSlot_bufferize_AW_id;
  reg        [3:0]    frontend_allocateSlot_bufferize_AW_region;
  reg        [7:0]    frontend_allocateSlot_bufferize_AW_len;
  reg        [2:0]    frontend_allocateSlot_bufferize_AW_size;
  reg        [1:0]    frontend_allocateSlot_bufferize_AW_burst;
  reg        [0:0]    frontend_allocateSlot_bufferize_AW_lock;
  reg        [3:0]    frontend_allocateSlot_bufferize_AW_cache;
  reg        [3:0]    frontend_allocateSlot_bufferize_AW_qos;
  reg        [2:0]    frontend_allocateSlot_bufferize_AW_prot;
  reg                 frontend_allocateSlot_split_spliter_LAST;
  wire       [2:0]    frontend_split_aligner_LEN;
  wire       [4:0]    frontend_split_aligner_CHUNK_END;
  wire       [4:0]    frontend_split_aligner_CHUNK_START;
  wire                frontend_split_isForked;
  wire       [2:0]    frontend_split_spliter_CHUNKS_WORDS;
  wire       [6:0]    frontend_split_spliter_BOUNDED_BLOCK;
  wire                frontend_split_spliter_FIRST;
  wire                frontend_split_spliter_LAST;
  reg        [31:0]   frontend_split_bufferize_AW_addr;
  reg        [3:0]    frontend_split_bufferize_AW_id;
  reg        [3:0]    frontend_split_bufferize_AW_region;
  reg        [7:0]    frontend_split_bufferize_AW_len;
  reg        [2:0]    frontend_split_bufferize_AW_size;
  reg        [1:0]    frontend_split_bufferize_AW_burst;
  reg        [0:0]    frontend_split_bufferize_AW_lock;
  reg        [3:0]    frontend_split_bufferize_AW_cache;
  reg        [3:0]    frontend_split_bufferize_AW_qos;
  reg        [2:0]    frontend_split_bufferize_AW_prot;
  wire       [31:0]   frontend_bufferize_AW_addr;
  wire       [3:0]    frontend_bufferize_AW_id;
  wire       [3:0]    frontend_bufferize_AW_region;
  wire       [7:0]    frontend_bufferize_AW_len;
  wire       [2:0]    frontend_bufferize_AW_size;
  wire       [1:0]    frontend_bufferize_AW_burst;
  wire       [0:0]    frontend_bufferize_AW_lock;
  wire       [3:0]    frontend_bufferize_AW_cache;
  wire       [3:0]    frontend_bufferize_AW_qos;
  wire       [2:0]    frontend_bufferize_AW_prot;
  wire                frontend_bufferize_ready;
  reg                 _zz_1;
  reg        [2:0]    ptr_cmd;
  reg        [2:0]    ptr_fetch;
  reg        [2:0]    ptr_rsp;
  wire                ptr_full;
  reg                 slots_0_done;
  reg                 slots_0_error;
  reg                 slots_1_done;
  reg                 slots_1_error;
  reg                 slots_2_done;
  reg                 slots_2_error;
  reg                 slots_3_done;
  reg                 slots_3_error;
  reg                 context_write_valid;
  wire       [1:0]    context_write_payload_address;
  wire                context_write_payload_data_last;
  wire       [3:0]    context_write_payload_data_id;
  reg                 context_read_cmd_valid;
  wire       [1:0]    context_read_cmd_payload;
  wire                context_read_rsp_last;
  wire       [3:0]    context_read_rsp_id;
  wire       [4:0]    _zz_context_read_rsp_last;
  wire                frontend_bufferize_valid;
  reg                 frontend_split_valid;
  wire                _zz_frontend_split_isForked;
  wire       [11:0]   frontend_split_spliter_boundedStart;
  wire       [11:0]   frontend_split_spliter_boundedEnd;
  wire       [6:0]    frontend_split_spliter_blockStart;
  wire       [6:0]    frontend_split_spliter_blockEnd;
  wire       [6:0]    frontend_split_spliter_blockCount;
  reg        [6:0]    frontend_split_spliter_blockCounter;
  wire       [2:0]    frontend_split_spliter_chunkWordStart;
  wire       [2:0]    frontend_split_spliter_chunkWordEnd;
  wire                frontend_split_forkRequest_Axi4Aligner_l83;
  reg        [1:0]    frontend_split_aligner_sizeToMask;
  wire       [2:0]    _zz_frontend_split_aligner_mask;
  reg        [2:0]    _zz_frontend_split_aligner_mask_1;
  wire       [4:0]    frontend_split_aligner_mask;
  reg                 frontend_allocateSlot_valid;
  wire                frontend_allocateSlot_haltRequest_Axi4Aligner_l105;
  wire                frontend_allocateSlot_isFireing;
  wire       [1:0]    switch_Utils_l1436;
  wire                frontend_allocateSlot_haltRequest_Axi4Aligner_l120;
  wire       [4:0]    frontend_allocateSlot_bytes;
  wire       [1:0]    frontend_allocateSlot_smallSize;
  wire                when_Axi4Aligner_l130;
  wire                frontend_allocateSlot_wCmd_valid;
  wire                frontend_allocateSlot_wCmd_ready;
  wire                frontend_allocateSlot_wCmd_payload_last;
  wire       [2:0]    frontend_allocateSlot_wCmd_payload_header;
  wire       [2:0]    frontend_allocateSlot_wCmd_payload_ups;
  wire       [2:0]    frontend_allocateSlot_wCmd_payload_len;
  wire                _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135;
  wire                _zz_frontend_allocateSlot_wCmd_valid;
  wire                _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135_1;
  reg                 _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135_2;
  wire                when_Axi4Aligner_l135;
  wire                frontend_allocateSlot_haltRequest_Axi4Aligner_l135;
  reg                 frontend_split_ready_output;
  reg                 frontend_split_ready;
  reg                 frontend_bufferize_ready_output;
  wire                when_Pipeline_l285;
  wire                when_Pipeline_l278;
  wire                when_Connection_l74;
  wire                when_Connection_l74_1;
  wire                frontend_allocateSlot_wCmd_s2mPipe_valid;
  reg                 frontend_allocateSlot_wCmd_s2mPipe_ready;
  wire                frontend_allocateSlot_wCmd_s2mPipe_payload_last;
  wire       [2:0]    frontend_allocateSlot_wCmd_s2mPipe_payload_header;
  wire       [2:0]    frontend_allocateSlot_wCmd_s2mPipe_payload_ups;
  wire       [2:0]    frontend_allocateSlot_wCmd_s2mPipe_payload_len;
  reg                 frontend_allocateSlot_wCmd_rValidN;
  reg                 frontend_allocateSlot_wCmd_rData_last;
  reg        [2:0]    frontend_allocateSlot_wCmd_rData_header;
  reg        [2:0]    frontend_allocateSlot_wCmd_rData_ups;
  reg        [2:0]    frontend_allocateSlot_wCmd_rData_len;
  wire                downW_cmd_valid;
  reg                 downW_cmd_ready;
  wire                downW_cmd_payload_last;
  wire       [2:0]    downW_cmd_payload_header;
  wire       [2:0]    downW_cmd_payload_ups;
  wire       [2:0]    downW_cmd_payload_len;
  reg                 frontend_allocateSlot_wCmd_s2mPipe_rValid;
  reg                 frontend_allocateSlot_wCmd_s2mPipe_rData_last;
  reg        [2:0]    frontend_allocateSlot_wCmd_s2mPipe_rData_header;
  reg        [2:0]    frontend_allocateSlot_wCmd_s2mPipe_rData_ups;
  reg        [2:0]    frontend_allocateSlot_wCmd_s2mPipe_rData_len;
  wire                when_Stream_l393;
  reg        [2:0]    downW_header;
  reg        [2:0]    downW_ups;
  reg        [2:0]    downW_len;
  wire                downW_headerDone;
  reg                 downW_upsDone;
  wire                downW_last;
  wire                when_Axi4Aligner_l160;
  wire                when_Axi4Aligner_l166;
  wire                when_Axi4Aligner_l163;
  wire                io_down_w_fire;
  wire                io_down_b_fire;
  wire                upB_fetch_valid;
  wire                upB_fetch_isFireing;
  reg                 upB_handle_valid;
  wire       [2:0]    _zz_upB_handle_done;
  wire                upB_handle_done;
  wire                upB_handle_error;
  reg                 upB_handle_errorAcc;
  wire                upB_handle_isFireing;
  wire                when_Axi4Aligner_l207;
  wire                when_Axi4Aligner_l212;
  wire                upB_handle_haltRequest_Axi4Aligner_l213;
  wire                io_up_b_isStall;
  wire                upB_handle_haltRequest_Axi4Aligner_l214;
  wire                when_Axi4Aligner_l218;
  reg                 upB_fetch_ready_output;
  wire                when_Pipeline_l278_1;
  wire                when_Connection_l74_2;
  reg [4:0] context_mem [0:3];

  assign _zz_frontend_split_spliter_boundedEnd = (frontend_split_bufferize_AW_addr + _zz_frontend_split_spliter_boundedEnd_1);
  assign _zz_frontend_split_spliter_boundedEnd_2 = ({2'd0,frontend_split_bufferize_AW_len} <<< 2'd2);
  assign _zz_frontend_split_spliter_boundedEnd_1 = {22'd0, _zz_frontend_split_spliter_boundedEnd_2};
  assign _zz_frontend_split_aligner_CHUNK_START = frontend_split_spliter_boundedStart[4:0];
  assign _zz_frontend_split_aligner_CHUNK_END = frontend_split_spliter_boundedEnd[4:0];
  assign _zz_frontend_allocateSlot_wCmd_payload_header = (_zz_frontend_allocateSlot_wCmd_payload_header_1 - frontend_allocateSlot_split_aligner_CHUNK_START);
  assign _zz_frontend_allocateSlot_wCmd_payload_header_1 = frontend_allocateSlot_bufferize_AW_addr[4:0];
  assign _zz_downW_header_1 = io_down_w_ready;
  assign _zz_downW_header = {2'd0, _zz_downW_header_1};
  assign _zz_downW_ups_1 = io_down_w_ready;
  assign _zz_downW_ups = {2'd0, _zz_downW_ups_1};
  assign _zz_upB_handle_done_2 = _zz_upB_handle_done[1:0];
  assign _zz_upB_handle_error_1 = _zz_upB_handle_done[1:0];
  assign _zz_context_mem_port = {context_write_payload_data_id,context_write_payload_data_last};
  assign _zz_frontend_allocateSlot_smallSize_1 = frontend_allocateSlot_bytes[1 : 0];
  always @(posedge clk) begin
    if(_zz_1) begin
      context_mem[context_write_payload_address] <= _zz_context_mem_port;
    end
  end

  always @(posedge clk) begin
    if(context_read_cmd_valid) begin
      context_mem_spinal_port1 <= context_mem[context_read_cmd_payload];
    end
  end

  always @(*) begin
    case(_zz_frontend_allocateSlot_smallSize_1)
      2'b00 : _zz_frontend_allocateSlot_smallSize = 2'b00;
      2'b01 : _zz_frontend_allocateSlot_smallSize = 2'b01;
      2'b10 : _zz_frontend_allocateSlot_smallSize = 2'b10;
      default : _zz_frontend_allocateSlot_smallSize = 2'b10;
    endcase
  end

  always @(*) begin
    case(_zz_upB_handle_done_2)
      2'b00 : _zz_upB_handle_done_1 = slots_0_done;
      2'b01 : _zz_upB_handle_done_1 = slots_1_done;
      2'b10 : _zz_upB_handle_done_1 = slots_2_done;
      default : _zz_upB_handle_done_1 = slots_3_done;
    endcase
  end

  always @(*) begin
    case(_zz_upB_handle_error_1)
      2'b00 : _zz_upB_handle_error = slots_0_error;
      2'b01 : _zz_upB_handle_error = slots_1_error;
      2'b10 : _zz_upB_handle_error = slots_2_error;
      default : _zz_upB_handle_error = slots_3_error;
    endcase
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(context_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign ptr_full = (((ptr_cmd ^ ptr_rsp) ^ 3'b100) == 3'b000);
  assign _zz_context_read_rsp_last = context_mem_spinal_port1;
  assign context_read_rsp_last = _zz_context_read_rsp_last[0];
  assign context_read_rsp_id = _zz_context_read_rsp_last[4 : 1];
  assign frontend_bufferize_valid = io_up_aw_valid;
  assign io_up_aw_ready = frontend_bufferize_ready;
  assign frontend_bufferize_AW_addr = io_up_aw_payload_addr;
  assign frontend_bufferize_AW_id = io_up_aw_payload_id;
  assign frontend_bufferize_AW_region = io_up_aw_payload_region;
  assign frontend_bufferize_AW_len = io_up_aw_payload_len;
  assign frontend_bufferize_AW_size = io_up_aw_payload_size;
  assign frontend_bufferize_AW_burst = io_up_aw_payload_burst;
  assign frontend_bufferize_AW_lock = io_up_aw_payload_lock;
  assign frontend_bufferize_AW_cache = io_up_aw_payload_cache;
  assign frontend_bufferize_AW_qos = io_up_aw_payload_qos;
  assign frontend_bufferize_AW_prot = io_up_aw_payload_prot;
  assign frontend_split_spliter_boundedStart = frontend_split_bufferize_AW_addr[11:0];
  assign frontend_split_spliter_boundedEnd = _zz_frontend_split_spliter_boundedEnd[11:0];
  assign frontend_split_spliter_blockStart = (frontend_split_spliter_boundedStart >>> 3'd5);
  assign frontend_split_spliter_blockEnd = (frontend_split_spliter_boundedEnd >>> 3'd5);
  assign frontend_split_spliter_blockCount = (frontend_split_spliter_blockEnd - frontend_split_spliter_blockStart);
  assign frontend_split_spliter_LAST = (frontend_split_spliter_blockCounter == frontend_split_spliter_blockCount);
  assign frontend_split_spliter_FIRST = (frontend_split_spliter_blockCounter == 7'h0);
  assign frontend_split_spliter_BOUNDED_BLOCK = (frontend_split_spliter_blockStart + frontend_split_spliter_blockCounter);
  assign frontend_split_spliter_chunkWordStart = (frontend_split_spliter_FIRST ? frontend_split_spliter_boundedStart[4 : 2] : 3'b000);
  assign frontend_split_spliter_chunkWordEnd = (frontend_split_spliter_LAST ? frontend_split_spliter_boundedEnd[4 : 2] : 3'b111);
  assign frontend_split_spliter_CHUNKS_WORDS = (frontend_split_spliter_chunkWordEnd - frontend_split_spliter_chunkWordStart);
  assign frontend_split_forkRequest_Axi4Aligner_l83 = (! frontend_split_spliter_LAST);
  always @(*) begin
    frontend_split_aligner_sizeToMask = 2'bxx;
    case(frontend_split_bufferize_AW_size)
      3'b000 : begin
        frontend_split_aligner_sizeToMask = 2'b00;
      end
      3'b001 : begin
        frontend_split_aligner_sizeToMask = 2'b01;
      end
      3'b010 : begin
        frontend_split_aligner_sizeToMask = 2'b11;
      end
      default : begin
      end
    endcase
  end

  assign _zz_frontend_split_aligner_mask = (frontend_split_spliter_chunkWordStart ^ frontend_split_spliter_chunkWordEnd);
  always @(*) begin
    _zz_frontend_split_aligner_mask_1[0] = (|_zz_frontend_split_aligner_mask[2 : 0]);
    _zz_frontend_split_aligner_mask_1[1] = (|_zz_frontend_split_aligner_mask[2 : 1]);
    _zz_frontend_split_aligner_mask_1[2] = (|_zz_frontend_split_aligner_mask[2 : 2]);
  end

  assign frontend_split_aligner_mask = {_zz_frontend_split_aligner_mask_1,((frontend_split_bufferize_AW_len != 8'h0) ? 2'b11 : frontend_split_aligner_sizeToMask)};
  assign frontend_split_aligner_CHUNK_START = (frontend_split_spliter_FIRST ? (_zz_frontend_split_aligner_CHUNK_START & (~ frontend_split_aligner_mask)) : 5'h0);
  assign frontend_split_aligner_CHUNK_END = ((! frontend_split_spliter_LAST) ? 5'h1f : (_zz_frontend_split_aligner_CHUNK_END | frontend_split_aligner_mask));
  assign frontend_split_aligner_LEN = (frontend_split_aligner_CHUNK_END[4 : 2] - frontend_split_aligner_CHUNK_START[4 : 2]);
  assign frontend_allocateSlot_haltRequest_Axi4Aligner_l105 = ptr_full;
  always @(*) begin
    context_write_valid = 1'b0;
    if(frontend_allocateSlot_isFireing) begin
      context_write_valid = 1'b1;
    end
  end

  assign context_write_payload_address = ptr_cmd[1:0];
  assign context_write_payload_data_last = frontend_allocateSlot_split_spliter_LAST;
  assign context_write_payload_data_id = frontend_allocateSlot_bufferize_AW_id;
  assign frontend_allocateSlot_isFireing = (frontend_allocateSlot_valid && frontend_allocateSlot_ready);
  assign switch_Utils_l1436 = ptr_cmd[1:0];
  assign frontend_allocateSlot_haltRequest_Axi4Aligner_l120 = (! io_down_aw_ready);
  assign io_down_aw_valid = (frontend_allocateSlot_valid && (! ptr_full));
  always @(*) begin
    io_down_aw_payload_addr = frontend_allocateSlot_bufferize_AW_addr;
    io_down_aw_payload_addr[4 : 0] = frontend_allocateSlot_split_aligner_CHUNK_START;
    io_down_aw_payload_addr[11 : 5] = frontend_allocateSlot_split_spliter_BOUNDED_BLOCK;
  end

  assign io_down_aw_payload_region = frontend_allocateSlot_bufferize_AW_region;
  always @(*) begin
    io_down_aw_payload_size = frontend_allocateSlot_bufferize_AW_size;
    if(when_Axi4Aligner_l130) begin
      io_down_aw_payload_size = {1'd0, frontend_allocateSlot_smallSize};
    end
  end

  assign io_down_aw_payload_burst = frontend_allocateSlot_bufferize_AW_burst;
  assign io_down_aw_payload_lock = frontend_allocateSlot_bufferize_AW_lock;
  assign io_down_aw_payload_cache = frontend_allocateSlot_bufferize_AW_cache;
  assign io_down_aw_payload_qos = frontend_allocateSlot_bufferize_AW_qos;
  assign io_down_aw_payload_prot = frontend_allocateSlot_bufferize_AW_prot;
  assign io_down_aw_payload_len = {5'd0, frontend_allocateSlot_split_aligner_LEN};
  assign io_down_aw_payload_id = ptr_cmd[1:0];
  assign frontend_allocateSlot_bytes = (frontend_allocateSlot_split_aligner_CHUNK_END - frontend_allocateSlot_split_aligner_CHUNK_START);
  assign frontend_allocateSlot_smallSize = _zz_frontend_allocateSlot_smallSize;
  assign when_Axi4Aligner_l130 = (frontend_allocateSlot_split_aligner_LEN == 3'b000);
  assign _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135 = (! ptr_full);
  assign when_Axi4Aligner_l135 = (frontend_allocateSlot_ready || frontend_allocateSlot_isRemoved);
  assign _zz_frontend_allocateSlot_wCmd_valid = ((frontend_allocateSlot_valid && (! _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135_2)) && _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135);
  assign frontend_allocateSlot_haltRequest_Axi4Aligner_l135 = (((! _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135_2) && (! _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135_1)) && _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135);
  assign frontend_allocateSlot_wCmd_valid = _zz_frontend_allocateSlot_wCmd_valid;
  assign _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135_1 = frontend_allocateSlot_wCmd_ready;
  assign frontend_allocateSlot_wCmd_payload_last = frontend_allocateSlot_split_spliter_LAST;
  assign frontend_allocateSlot_wCmd_payload_header = (frontend_allocateSlot_split_spliter_FIRST ? _zz_frontend_allocateSlot_wCmd_payload_header[4 : 2] : 3'b000);
  assign frontend_allocateSlot_wCmd_payload_ups = frontend_allocateSlot_split_spliter_CHUNKS_WORDS;
  assign frontend_allocateSlot_wCmd_payload_len = frontend_allocateSlot_split_aligner_LEN;
  assign frontend_allocateSlot_isRemoved = (frontend_allocateSlot_isFlushed || frontend_allocateSlot_isThrown);
  assign frontend_allocateSlot_isFlushed = 1'b0;
  assign frontend_allocateSlot_isThrown = 1'b0;
  assign frontend_split_isForked = (_zz_frontend_split_isForked && frontend_split_ready_output);
  assign frontend_bufferize_ready = frontend_bufferize_ready_output;
  assign _zz_frontend_split_isForked = frontend_split_valid;
  always @(*) begin
    frontend_split_ready = frontend_split_ready_output;
    if(when_Pipeline_l285) begin
      frontend_split_ready = 1'b0;
    end
  end

  assign when_Pipeline_l285 = (|frontend_split_forkRequest_Axi4Aligner_l83);
  always @(*) begin
    frontend_allocateSlot_ready = 1'b1;
    if(when_Pipeline_l278) begin
      frontend_allocateSlot_ready = 1'b0;
    end
  end

  assign when_Pipeline_l278 = (|{frontend_allocateSlot_haltRequest_Axi4Aligner_l135,{frontend_allocateSlot_haltRequest_Axi4Aligner_l120,frontend_allocateSlot_haltRequest_Axi4Aligner_l105}});
  always @(*) begin
    frontend_bufferize_ready_output = frontend_split_ready;
    if(when_Connection_l74) begin
      frontend_bufferize_ready_output = 1'b1;
    end
  end

  assign when_Connection_l74 = (! frontend_split_valid);
  always @(*) begin
    frontend_split_ready_output = frontend_allocateSlot_ready;
    if(when_Connection_l74_1) begin
      frontend_split_ready_output = 1'b1;
    end
  end

  assign when_Connection_l74_1 = (! frontend_allocateSlot_valid);
  assign frontend_allocateSlot_wCmd_ready = frontend_allocateSlot_wCmd_rValidN;
  assign frontend_allocateSlot_wCmd_s2mPipe_valid = (frontend_allocateSlot_wCmd_valid || (! frontend_allocateSlot_wCmd_rValidN));
  assign frontend_allocateSlot_wCmd_s2mPipe_payload_last = (frontend_allocateSlot_wCmd_rValidN ? frontend_allocateSlot_wCmd_payload_last : frontend_allocateSlot_wCmd_rData_last);
  assign frontend_allocateSlot_wCmd_s2mPipe_payload_header = (frontend_allocateSlot_wCmd_rValidN ? frontend_allocateSlot_wCmd_payload_header : frontend_allocateSlot_wCmd_rData_header);
  assign frontend_allocateSlot_wCmd_s2mPipe_payload_ups = (frontend_allocateSlot_wCmd_rValidN ? frontend_allocateSlot_wCmd_payload_ups : frontend_allocateSlot_wCmd_rData_ups);
  assign frontend_allocateSlot_wCmd_s2mPipe_payload_len = (frontend_allocateSlot_wCmd_rValidN ? frontend_allocateSlot_wCmd_payload_len : frontend_allocateSlot_wCmd_rData_len);
  always @(*) begin
    frontend_allocateSlot_wCmd_s2mPipe_ready = downW_cmd_ready;
    if(when_Stream_l393) begin
      frontend_allocateSlot_wCmd_s2mPipe_ready = 1'b1;
    end
  end

  assign when_Stream_l393 = (! downW_cmd_valid);
  assign downW_cmd_valid = frontend_allocateSlot_wCmd_s2mPipe_rValid;
  assign downW_cmd_payload_last = frontend_allocateSlot_wCmd_s2mPipe_rData_last;
  assign downW_cmd_payload_header = frontend_allocateSlot_wCmd_s2mPipe_rData_header;
  assign downW_cmd_payload_ups = frontend_allocateSlot_wCmd_s2mPipe_rData_ups;
  assign downW_cmd_payload_len = frontend_allocateSlot_wCmd_s2mPipe_rData_len;
  assign downW_headerDone = (downW_header == downW_cmd_payload_header);
  assign downW_last = (downW_len == downW_cmd_payload_len);
  always @(*) begin
    io_down_w_valid = 1'b0;
    if(downW_cmd_valid) begin
      if(when_Axi4Aligner_l160) begin
        io_down_w_valid = 1'b1;
      end else begin
        if(when_Axi4Aligner_l163) begin
          io_down_w_valid = io_up_w_valid;
        end else begin
          io_down_w_valid = 1'b1;
        end
      end
    end
  end

  assign io_down_w_payload_data = io_up_w_payload_data;
  assign io_down_w_payload_strb = ((downW_headerDone && (! downW_upsDone)) ? io_up_w_payload_strb : 4'b0000);
  assign io_down_w_payload_last = downW_last;
  always @(*) begin
    io_up_w_ready = 1'b0;
    if(downW_cmd_valid) begin
      if(!when_Axi4Aligner_l160) begin
        if(when_Axi4Aligner_l163) begin
          io_up_w_ready = io_down_w_ready;
        end
      end
    end
  end

  always @(*) begin
    downW_cmd_ready = 1'b0;
    if(io_down_w_fire) begin
      if(downW_last) begin
        downW_cmd_ready = 1'b1;
      end
    end
  end

  assign when_Axi4Aligner_l160 = (! downW_headerDone);
  assign when_Axi4Aligner_l166 = ((downW_ups == downW_cmd_payload_ups) && io_down_w_ready);
  assign when_Axi4Aligner_l163 = (! downW_upsDone);
  assign io_down_w_fire = (io_down_w_valid && io_down_w_ready);
  assign io_down_b_ready = 1'b1;
  assign io_down_b_fire = (io_down_b_valid && io_down_b_ready);
  assign upB_fetch_valid = (ptr_cmd != ptr_fetch);
  always @(*) begin
    context_read_cmd_valid = 1'b0;
    if(upB_fetch_isFireing) begin
      context_read_cmd_valid = 1'b1;
    end
  end

  assign context_read_cmd_payload = ptr_fetch[1:0];
  assign upB_fetch_isFireing = (upB_fetch_valid && upB_fetch_ready);
  assign upB_handle_CTX_last = context_read_rsp_last;
  assign upB_handle_CTX_id = context_read_rsp_id;
  assign _zz_upB_handle_done = ptr_rsp;
  assign upB_handle_done = _zz_upB_handle_done_1;
  assign upB_handle_error = _zz_upB_handle_error;
  assign upB_handle_isFireing = (upB_handle_valid && upB_handle_ready);
  assign when_Axi4Aligner_l207 = (upB_handle_isFireing && upB_handle_error);
  always @(*) begin
    io_up_b_valid = 1'b0;
    if(when_Axi4Aligner_l218) begin
      if(upB_handle_CTX_last) begin
        io_up_b_valid = 1'b1;
      end
    end
  end

  assign io_up_b_payload_id = upB_handle_CTX_id;
  always @(*) begin
    io_up_b_payload_resp = 2'b00;
    if(when_Axi4Aligner_l212) begin
      io_up_b_payload_resp = 2'b10;
    end
  end

  assign when_Axi4Aligner_l212 = (upB_handle_error || upB_handle_errorAcc);
  assign upB_handle_haltRequest_Axi4Aligner_l213 = (! upB_handle_done);
  assign io_up_b_isStall = (io_up_b_valid && (! io_up_b_ready));
  assign upB_handle_haltRequest_Axi4Aligner_l214 = io_up_b_isStall;
  assign when_Axi4Aligner_l218 = (upB_handle_valid && upB_handle_done);
  assign upB_fetch_ready = upB_fetch_ready_output;
  always @(*) begin
    upB_handle_ready = 1'b1;
    if(when_Pipeline_l278_1) begin
      upB_handle_ready = 1'b0;
    end
  end

  assign when_Pipeline_l278_1 = (|{upB_handle_haltRequest_Axi4Aligner_l214,upB_handle_haltRequest_Axi4Aligner_l213});
  always @(*) begin
    upB_fetch_ready_output = upB_handle_ready;
    if(when_Connection_l74_2) begin
      upB_fetch_ready_output = 1'b1;
    end
  end

  assign when_Connection_l74_2 = (! upB_handle_valid);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ptr_cmd <= 3'b000;
      ptr_fetch <= 3'b000;
      ptr_rsp <= 3'b000;
      frontend_split_spliter_blockCounter <= 7'h0;
      _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135_2 <= 1'b0;
      frontend_split_valid <= 1'b0;
      frontend_allocateSlot_valid <= 1'b0;
      frontend_allocateSlot_wCmd_rValidN <= 1'b1;
      frontend_allocateSlot_wCmd_s2mPipe_rValid <= 1'b0;
      downW_header <= 3'b000;
      downW_ups <= 3'b000;
      downW_len <= 3'b000;
      downW_upsDone <= 1'b0;
      upB_handle_errorAcc <= 1'b0;
      upB_handle_valid <= 1'b0;
    end else begin
      if(frontend_split_isForked) begin
        frontend_split_spliter_blockCounter <= (frontend_split_spliter_blockCounter + 7'h01);
        if(frontend_split_spliter_LAST) begin
          frontend_split_spliter_blockCounter <= 7'h0;
        end
      end
      if(frontend_allocateSlot_isFireing) begin
        ptr_cmd <= (ptr_cmd + 3'b001);
      end
      if((_zz_frontend_allocateSlot_wCmd_valid && _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135_1)) begin
        _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135_2 <= 1'b1;
      end
      if(when_Axi4Aligner_l135) begin
        _zz_frontend_allocateSlot_haltRequest_Axi4Aligner_l135_2 <= 1'b0;
      end
      if(frontend_bufferize_ready_output) begin
        frontend_split_valid <= frontend_bufferize_valid;
      end
      if(frontend_split_ready_output) begin
        frontend_allocateSlot_valid <= _zz_frontend_split_isForked;
      end
      if(frontend_allocateSlot_wCmd_valid) begin
        frontend_allocateSlot_wCmd_rValidN <= 1'b0;
      end
      if(frontend_allocateSlot_wCmd_s2mPipe_ready) begin
        frontend_allocateSlot_wCmd_rValidN <= 1'b1;
      end
      if(frontend_allocateSlot_wCmd_s2mPipe_ready) begin
        frontend_allocateSlot_wCmd_s2mPipe_rValid <= frontend_allocateSlot_wCmd_s2mPipe_valid;
      end
      if(downW_cmd_valid) begin
        if(when_Axi4Aligner_l160) begin
          downW_header <= (downW_header + _zz_downW_header);
        end else begin
          if(when_Axi4Aligner_l163) begin
            downW_ups <= (downW_ups + _zz_downW_ups);
            if(when_Axi4Aligner_l166) begin
              downW_upsDone <= 1'b1;
            end
          end
        end
      end
      if(io_down_w_fire) begin
        downW_len <= (downW_len + 3'b001);
        if(downW_last) begin
          downW_header <= 3'b000;
          downW_ups <= 3'b000;
          downW_len <= 3'b000;
          downW_upsDone <= 1'b0;
        end
      end
      if(upB_fetch_isFireing) begin
        ptr_fetch <= (ptr_fetch + 3'b001);
      end
      if(when_Axi4Aligner_l207) begin
        upB_handle_errorAcc <= 1'b1;
      end
      if(upB_handle_isFireing) begin
        ptr_rsp <= (ptr_rsp + 3'b001);
      end
      if(when_Axi4Aligner_l218) begin
        if(upB_handle_CTX_last) begin
          if(io_up_b_ready) begin
            upB_handle_errorAcc <= 1'b0;
          end
        end
      end
      if(upB_fetch_ready_output) begin
        upB_handle_valid <= upB_fetch_valid;
      end
    end
  end

  always @(posedge clk) begin
    if(frontend_allocateSlot_isFireing) begin
      case(switch_Utils_l1436)
        2'b00 : begin
          slots_0_done <= 1'b0;
          slots_0_error <= 1'b0;
        end
        2'b01 : begin
          slots_1_done <= 1'b0;
          slots_1_error <= 1'b0;
        end
        2'b10 : begin
          slots_2_done <= 1'b0;
          slots_2_error <= 1'b0;
        end
        default : begin
          slots_3_done <= 1'b0;
          slots_3_error <= 1'b0;
        end
      endcase
    end
    if(frontend_bufferize_ready_output) begin
      frontend_split_bufferize_AW_addr <= frontend_bufferize_AW_addr;
      frontend_split_bufferize_AW_id <= frontend_bufferize_AW_id;
      frontend_split_bufferize_AW_region <= frontend_bufferize_AW_region;
      frontend_split_bufferize_AW_len <= frontend_bufferize_AW_len;
      frontend_split_bufferize_AW_size <= frontend_bufferize_AW_size;
      frontend_split_bufferize_AW_burst <= frontend_bufferize_AW_burst;
      frontend_split_bufferize_AW_lock <= frontend_bufferize_AW_lock;
      frontend_split_bufferize_AW_cache <= frontend_bufferize_AW_cache;
      frontend_split_bufferize_AW_qos <= frontend_bufferize_AW_qos;
      frontend_split_bufferize_AW_prot <= frontend_bufferize_AW_prot;
    end
    if(frontend_split_ready_output) begin
      frontend_allocateSlot_bufferize_AW_addr <= frontend_split_bufferize_AW_addr;
      frontend_allocateSlot_bufferize_AW_id <= frontend_split_bufferize_AW_id;
      frontend_allocateSlot_bufferize_AW_region <= frontend_split_bufferize_AW_region;
      frontend_allocateSlot_bufferize_AW_len <= frontend_split_bufferize_AW_len;
      frontend_allocateSlot_bufferize_AW_size <= frontend_split_bufferize_AW_size;
      frontend_allocateSlot_bufferize_AW_burst <= frontend_split_bufferize_AW_burst;
      frontend_allocateSlot_bufferize_AW_lock <= frontend_split_bufferize_AW_lock;
      frontend_allocateSlot_bufferize_AW_cache <= frontend_split_bufferize_AW_cache;
      frontend_allocateSlot_bufferize_AW_qos <= frontend_split_bufferize_AW_qos;
      frontend_allocateSlot_bufferize_AW_prot <= frontend_split_bufferize_AW_prot;
      frontend_allocateSlot_split_spliter_LAST <= frontend_split_spliter_LAST;
      frontend_allocateSlot_split_spliter_FIRST <= frontend_split_spliter_FIRST;
      frontend_allocateSlot_split_spliter_BOUNDED_BLOCK <= frontend_split_spliter_BOUNDED_BLOCK;
      frontend_allocateSlot_split_spliter_CHUNKS_WORDS <= frontend_split_spliter_CHUNKS_WORDS;
      frontend_allocateSlot_split_aligner_CHUNK_START <= frontend_split_aligner_CHUNK_START;
      frontend_allocateSlot_split_aligner_CHUNK_END <= frontend_split_aligner_CHUNK_END;
      frontend_allocateSlot_split_aligner_LEN <= frontend_split_aligner_LEN;
    end
    if(frontend_allocateSlot_wCmd_ready) begin
      frontend_allocateSlot_wCmd_rData_last <= frontend_allocateSlot_wCmd_payload_last;
      frontend_allocateSlot_wCmd_rData_header <= frontend_allocateSlot_wCmd_payload_header;
      frontend_allocateSlot_wCmd_rData_ups <= frontend_allocateSlot_wCmd_payload_ups;
      frontend_allocateSlot_wCmd_rData_len <= frontend_allocateSlot_wCmd_payload_len;
    end
    if(frontend_allocateSlot_wCmd_s2mPipe_ready) begin
      frontend_allocateSlot_wCmd_s2mPipe_rData_last <= frontend_allocateSlot_wCmd_s2mPipe_payload_last;
      frontend_allocateSlot_wCmd_s2mPipe_rData_header <= frontend_allocateSlot_wCmd_s2mPipe_payload_header;
      frontend_allocateSlot_wCmd_s2mPipe_rData_ups <= frontend_allocateSlot_wCmd_s2mPipe_payload_ups;
      frontend_allocateSlot_wCmd_s2mPipe_rData_len <= frontend_allocateSlot_wCmd_s2mPipe_payload_len;
    end
    if(io_down_b_fire) begin
      case(io_down_b_payload_id)
        2'b00 : begin
          slots_0_done <= 1'b1;
          slots_0_error <= (! (io_down_b_payload_resp == 2'b00));
        end
        2'b01 : begin
          slots_1_done <= 1'b1;
          slots_1_error <= (! (io_down_b_payload_resp == 2'b00));
        end
        2'b10 : begin
          slots_2_done <= 1'b1;
          slots_2_error <= (! (io_down_b_payload_resp == 2'b00));
        end
        default : begin
          slots_3_done <= 1'b1;
          slots_3_error <= (! (io_down_b_payload_resp == 2'b00));
        end
      endcase
    end
  end


endmodule

module Axi4WriteOnlyCompactor (
  input  wire          io_up_aw_valid,
  output reg           io_up_aw_ready,
  input  wire [31:0]   io_up_aw_payload_addr,
  input  wire [3:0]    io_up_aw_payload_id,
  input  wire [3:0]    io_up_aw_payload_region,
  input  wire [7:0]    io_up_aw_payload_len,
  input  wire [2:0]    io_up_aw_payload_size,
  input  wire [1:0]    io_up_aw_payload_burst,
  input  wire [0:0]    io_up_aw_payload_lock,
  input  wire [3:0]    io_up_aw_payload_cache,
  input  wire [3:0]    io_up_aw_payload_qos,
  input  wire [2:0]    io_up_aw_payload_prot,
  input  wire          io_up_w_valid,
  output reg           io_up_w_ready,
  input  wire [31:0]   io_up_w_payload_data,
  input  wire [3:0]    io_up_w_payload_strb,
  input  wire          io_up_w_payload_last,
  output wire          io_up_b_valid,
  input  wire          io_up_b_ready,
  output wire [3:0]    io_up_b_payload_id,
  output wire [1:0]    io_up_b_payload_resp,
  output wire          io_down_aw_valid,
  input  wire          io_down_aw_ready,
  output wire [31:0]   io_down_aw_payload_addr,
  output wire [3:0]    io_down_aw_payload_id,
  output wire [3:0]    io_down_aw_payload_region,
  output wire [7:0]    io_down_aw_payload_len,
  output wire [2:0]    io_down_aw_payload_size,
  output wire [1:0]    io_down_aw_payload_burst,
  output wire [0:0]    io_down_aw_payload_lock,
  output wire [3:0]    io_down_aw_payload_cache,
  output wire [3:0]    io_down_aw_payload_qos,
  output wire [2:0]    io_down_aw_payload_prot,
  output wire          io_down_w_valid,
  input  wire          io_down_w_ready,
  output wire [31:0]   io_down_w_payload_data,
  output wire [3:0]    io_down_w_payload_strb,
  output wire          io_down_w_payload_last,
  input  wire          io_down_b_valid,
  output wire          io_down_b_ready,
  input  wire [3:0]    io_down_b_payload_id,
  input  wire [1:0]    io_down_b_payload_resp,
  input  wire          clk,
  input  wire          reset
);

  wire       [14:0]   _zz_onAw_bytes;
  wire       [14:0]   _zz_onAw_bytes_1;
  wire       [14:0]   _zz_onAw_bytesBeats;
  wire       [1:0]    _zz_onAw_bytesBeats_1;
  wire       [1:0]    _zz_onAw_bytesBeats_2;
  wire       [1:0]    _zz_onAw_bytesBeats_3;
  reg        [1:0]    _zz_onAw_smallSize;
  wire       [1:0]    _zz_onAw_smallSize_1;
  wire       [1:0]    _zz_io_down_aw_payload_size;
  wire       [12:0]   _zz_io_down_aw_payload_len;
  wire       [7:0]    _zz_onAw_toW_payload_bytePerBeat;
  wire       [7:0]    _zz_onAw_toW_payload_bytePerBeat_1;
  wire       [2:0]    _zz_onW_counterPlus;
  wire                onAw_downFork_valid;
  wire                onAw_downFork_ready;
  wire       [31:0]   onAw_downFork_payload_addr;
  wire       [3:0]    onAw_downFork_payload_id;
  wire       [3:0]    onAw_downFork_payload_region;
  wire       [7:0]    onAw_downFork_payload_len;
  wire       [2:0]    onAw_downFork_payload_size;
  wire       [1:0]    onAw_downFork_payload_burst;
  wire       [0:0]    onAw_downFork_payload_lock;
  wire       [3:0]    onAw_downFork_payload_cache;
  wire       [3:0]    onAw_downFork_payload_qos;
  wire       [2:0]    onAw_downFork_payload_prot;
  wire                onAw_wFork_valid;
  wire                onAw_wFork_ready;
  wire       [31:0]   onAw_wFork_payload_addr;
  wire       [3:0]    onAw_wFork_payload_id;
  wire       [3:0]    onAw_wFork_payload_region;
  wire       [7:0]    onAw_wFork_payload_len;
  wire       [2:0]    onAw_wFork_payload_size;
  wire       [1:0]    onAw_wFork_payload_burst;
  wire       [0:0]    onAw_wFork_payload_lock;
  wire       [3:0]    onAw_wFork_payload_cache;
  wire       [3:0]    onAw_wFork_payload_qos;
  wire       [2:0]    onAw_wFork_payload_prot;
  reg                 io_up_aw_fork2_logic_linkEnable_0;
  reg                 io_up_aw_fork2_logic_linkEnable_1;
  wire                when_Stream_l1084;
  wire                when_Stream_l1084_1;
  wire                onAw_downFork_fire;
  wire                onAw_wFork_fire;
  reg        [1:0]    onAw_sizeBytes;
  wire       [14:0]   onAw_bytes;
  wire       [14:0]   onAw_bytesBeats;
  wire       [1:0]    onAw_smallSize;
  wire                onAw_toW_valid;
  wire                onAw_toW_ready;
  wire       [7:0]    onAw_toW_payload_len;
  wire       [1:0]    onAw_toW_payload_bytePerBeat;
  wire       [1:0]    onAw_toW_payload_offset;
  wire                onW_awS2m_valid;
  reg                 onW_awS2m_ready;
  wire       [7:0]    onW_awS2m_payload_len;
  wire       [1:0]    onW_awS2m_payload_bytePerBeat;
  wire       [1:0]    onW_awS2m_payload_offset;
  reg                 onAw_toW_rValidN;
  reg        [7:0]    onAw_toW_rData_len;
  reg        [1:0]    onAw_toW_rData_bytePerBeat;
  reg        [1:0]    onAw_toW_rData_offset;
  wire                onW_aw_valid;
  reg                 onW_aw_ready;
  wire       [7:0]    onW_aw_payload_len;
  wire       [1:0]    onW_aw_payload_bytePerBeat;
  wire       [1:0]    onW_aw_payload_offset;
  reg                 onW_awS2m_rValid;
  reg        [7:0]    onW_awS2m_rData_len;
  reg        [1:0]    onW_awS2m_rData_bytePerBeat;
  reg        [1:0]    onW_awS2m_rData_offset;
  wire                when_Stream_l393;
  reg                 onW_commitCmd_valid;
  reg                 onW_commitCmd_ready;
  wire                onW_commitDo_valid;
  wire                onW_commitDo_ready;
  reg                 onW_commitCmd_rValid;
  wire                when_Stream_l393_1;
  reg                 onW_firstCycle;
  reg        [7:0]    onW_buffer_0_data;
  reg                 onW_buffer_0_strb;
  wire                onW_commitDo_fire;
  wire                when_Axi4Compactor_l53;
  reg        [7:0]    onW_buffer_1_data;
  reg                 onW_buffer_1_strb;
  wire                when_Axi4Compactor_l53_1;
  reg        [7:0]    onW_buffer_2_data;
  reg                 onW_buffer_2_strb;
  wire                when_Axi4Compactor_l53_2;
  reg        [7:0]    onW_buffer_3_data;
  reg                 onW_buffer_3_strb;
  wire                when_Axi4Compactor_l53_3;
  reg                 onW_bufferLast;
  wire       [1:0]    onW_mask;
  reg        [1:0]    onW_counter;
  wire       [2:0]    onW_counterPlus;
  wire                onW_last;
  wire                when_Axi4Compactor_l66;
  wire                onW_commitDo_isStall;
  wire                io_up_w_fire;
  wire                when_Axi4Compactor_l74;
  wire                when_Axi4Compactor_l74_1;
  wire                when_Axi4Compactor_l74_2;
  wire                when_Axi4Compactor_l74_3;
  wire                onW_awS2m_fire;

  assign _zz_onAw_bytes = ({7'd0,io_up_aw_payload_len} <<< io_up_aw_payload_size);
  assign _zz_onAw_bytes_1 = {13'd0, onAw_sizeBytes};
  assign _zz_onAw_bytesBeats_1 = (io_up_aw_payload_addr[1 : 0] & (~ _zz_onAw_bytesBeats_2));
  assign _zz_onAw_bytesBeats = {13'd0, _zz_onAw_bytesBeats_1};
  assign _zz_onAw_bytesBeats_2 = (_zz_onAw_bytesBeats_3 - 2'b01);
  assign _zz_onAw_bytesBeats_3 = (2'b01 <<< io_up_aw_payload_size);
  assign _zz_io_down_aw_payload_size = ((|io_down_aw_payload_len) ? 2'b10 : onAw_smallSize);
  assign _zz_io_down_aw_payload_len = (onAw_bytesBeats >>> 2'd2);
  assign _zz_onAw_toW_payload_bytePerBeat = (_zz_onAw_toW_payload_bytePerBeat_1 - 8'h01);
  assign _zz_onAw_toW_payload_bytePerBeat_1 = ({7'd0,1'b1} <<< onAw_wFork_payload_size);
  assign _zz_onW_counterPlus = ({1'b0,onW_counter} + {1'b0,onW_aw_payload_bytePerBeat});
  assign _zz_onAw_smallSize_1 = onAw_bytesBeats[1 : 0];
  always @(*) begin
    case(_zz_onAw_smallSize_1)
      2'b00 : _zz_onAw_smallSize = 2'b00;
      2'b01 : _zz_onAw_smallSize = 2'b01;
      2'b10 : _zz_onAw_smallSize = 2'b10;
      default : _zz_onAw_smallSize = 2'b10;
    endcase
  end

  always @(*) begin
    io_up_aw_ready = 1'b1;
    if(when_Stream_l1084) begin
      io_up_aw_ready = 1'b0;
    end
    if(when_Stream_l1084_1) begin
      io_up_aw_ready = 1'b0;
    end
  end

  assign when_Stream_l1084 = ((! onAw_downFork_ready) && io_up_aw_fork2_logic_linkEnable_0);
  assign when_Stream_l1084_1 = ((! onAw_wFork_ready) && io_up_aw_fork2_logic_linkEnable_1);
  assign onAw_downFork_valid = (io_up_aw_valid && io_up_aw_fork2_logic_linkEnable_0);
  assign onAw_downFork_payload_addr = io_up_aw_payload_addr;
  assign onAw_downFork_payload_id = io_up_aw_payload_id;
  assign onAw_downFork_payload_region = io_up_aw_payload_region;
  assign onAw_downFork_payload_len = io_up_aw_payload_len;
  assign onAw_downFork_payload_size = io_up_aw_payload_size;
  assign onAw_downFork_payload_burst = io_up_aw_payload_burst;
  assign onAw_downFork_payload_lock = io_up_aw_payload_lock;
  assign onAw_downFork_payload_cache = io_up_aw_payload_cache;
  assign onAw_downFork_payload_qos = io_up_aw_payload_qos;
  assign onAw_downFork_payload_prot = io_up_aw_payload_prot;
  assign onAw_downFork_fire = (onAw_downFork_valid && onAw_downFork_ready);
  assign onAw_wFork_valid = (io_up_aw_valid && io_up_aw_fork2_logic_linkEnable_1);
  assign onAw_wFork_payload_addr = io_up_aw_payload_addr;
  assign onAw_wFork_payload_id = io_up_aw_payload_id;
  assign onAw_wFork_payload_region = io_up_aw_payload_region;
  assign onAw_wFork_payload_len = io_up_aw_payload_len;
  assign onAw_wFork_payload_size = io_up_aw_payload_size;
  assign onAw_wFork_payload_burst = io_up_aw_payload_burst;
  assign onAw_wFork_payload_lock = io_up_aw_payload_lock;
  assign onAw_wFork_payload_cache = io_up_aw_payload_cache;
  assign onAw_wFork_payload_qos = io_up_aw_payload_qos;
  assign onAw_wFork_payload_prot = io_up_aw_payload_prot;
  assign onAw_wFork_fire = (onAw_wFork_valid && onAw_wFork_ready);
  assign io_down_aw_valid = onAw_downFork_valid;
  assign onAw_downFork_ready = io_down_aw_ready;
  assign io_down_aw_payload_addr = onAw_downFork_payload_addr;
  assign io_down_aw_payload_id = onAw_downFork_payload_id;
  assign io_down_aw_payload_region = onAw_downFork_payload_region;
  assign io_down_aw_payload_burst = onAw_downFork_payload_burst;
  assign io_down_aw_payload_lock = onAw_downFork_payload_lock;
  assign io_down_aw_payload_cache = onAw_downFork_payload_cache;
  assign io_down_aw_payload_qos = onAw_downFork_payload_qos;
  assign io_down_aw_payload_prot = onAw_downFork_payload_prot;
  always @(*) begin
    onAw_sizeBytes = 2'bxx;
    case(io_up_aw_payload_size)
      3'b000 : begin
        onAw_sizeBytes = 2'b00;
      end
      3'b001 : begin
        onAw_sizeBytes = 2'b01;
      end
      3'b010 : begin
        onAw_sizeBytes = 2'b11;
      end
      default : begin
      end
    endcase
  end

  assign onAw_bytes = (_zz_onAw_bytes + _zz_onAw_bytes_1);
  assign onAw_bytesBeats = (onAw_bytes + _zz_onAw_bytesBeats);
  assign onAw_smallSize = _zz_onAw_smallSize;
  assign io_down_aw_payload_size = {1'd0, _zz_io_down_aw_payload_size};
  assign io_down_aw_payload_len = _zz_io_down_aw_payload_len[7:0];
  assign onAw_toW_valid = onAw_wFork_valid;
  assign onAw_wFork_ready = onAw_toW_ready;
  assign onAw_toW_payload_len = onAw_wFork_payload_len;
  assign onAw_toW_payload_bytePerBeat = _zz_onAw_toW_payload_bytePerBeat[1:0];
  assign onAw_toW_payload_offset = (onAw_wFork_payload_addr[1 : 0] & (~ onAw_toW_payload_bytePerBeat));
  assign onAw_toW_ready = onAw_toW_rValidN;
  assign onW_awS2m_valid = (onAw_toW_valid || (! onAw_toW_rValidN));
  assign onW_awS2m_payload_len = (onAw_toW_rValidN ? onAw_toW_payload_len : onAw_toW_rData_len);
  assign onW_awS2m_payload_bytePerBeat = (onAw_toW_rValidN ? onAw_toW_payload_bytePerBeat : onAw_toW_rData_bytePerBeat);
  assign onW_awS2m_payload_offset = (onAw_toW_rValidN ? onAw_toW_payload_offset : onAw_toW_rData_offset);
  always @(*) begin
    onW_awS2m_ready = onW_aw_ready;
    if(when_Stream_l393) begin
      onW_awS2m_ready = 1'b1;
    end
  end

  assign when_Stream_l393 = (! onW_aw_valid);
  assign onW_aw_valid = onW_awS2m_rValid;
  assign onW_aw_payload_len = onW_awS2m_rData_len;
  assign onW_aw_payload_bytePerBeat = onW_awS2m_rData_bytePerBeat;
  assign onW_aw_payload_offset = onW_awS2m_rData_offset;
  always @(*) begin
    onW_commitCmd_ready = onW_commitDo_ready;
    if(when_Stream_l393_1) begin
      onW_commitCmd_ready = 1'b1;
    end
  end

  assign when_Stream_l393_1 = (! onW_commitDo_valid);
  assign onW_commitDo_valid = onW_commitCmd_rValid;
  assign onW_commitDo_fire = (onW_commitDo_valid && onW_commitDo_ready);
  assign when_Axi4Compactor_l53 = (onW_commitDo_fire || onW_firstCycle);
  assign when_Axi4Compactor_l53_1 = (onW_commitDo_fire || onW_firstCycle);
  assign when_Axi4Compactor_l53_2 = (onW_commitDo_fire || onW_firstCycle);
  assign when_Axi4Compactor_l53_3 = (onW_commitDo_fire || onW_firstCycle);
  assign onW_mask = (~ onW_aw_payload_bytePerBeat);
  assign onW_counterPlus = (_zz_onW_counterPlus + 3'b001);
  assign onW_last = (onW_counterPlus[2] || io_up_w_payload_last);
  always @(*) begin
    onW_aw_ready = 1'b0;
    if(io_up_w_fire) begin
      onW_aw_ready = io_up_w_payload_last;
    end
  end

  always @(*) begin
    io_up_w_ready = 1'b0;
    if(when_Axi4Compactor_l66) begin
      io_up_w_ready = (! onW_commitDo_isStall);
    end
  end

  always @(*) begin
    onW_commitCmd_valid = 1'b0;
    if(when_Axi4Compactor_l66) begin
      onW_commitCmd_valid = onW_last;
    end
  end

  assign when_Axi4Compactor_l66 = (onW_aw_valid && io_up_w_valid);
  assign onW_commitDo_isStall = (onW_commitDo_valid && (! onW_commitDo_ready));
  assign io_up_w_fire = (io_up_w_valid && io_up_w_ready);
  assign when_Axi4Compactor_l74 = (onW_counter == (2'b00 & onW_mask));
  assign when_Axi4Compactor_l74_1 = (onW_counter == (2'b01 & onW_mask));
  assign when_Axi4Compactor_l74_2 = (onW_counter == (2'b10 & onW_mask));
  assign when_Axi4Compactor_l74_3 = (onW_counter == (2'b11 & onW_mask));
  assign onW_awS2m_fire = (onW_awS2m_valid && onW_awS2m_ready);
  assign io_down_w_valid = onW_commitDo_valid;
  assign onW_commitDo_ready = io_down_w_ready;
  assign io_down_w_payload_data = {onW_buffer_3_data,{onW_buffer_2_data,{onW_buffer_1_data,onW_buffer_0_data}}};
  assign io_down_w_payload_strb = {onW_buffer_3_strb,{onW_buffer_2_strb,{onW_buffer_1_strb,onW_buffer_0_strb}}};
  assign io_down_w_payload_last = onW_bufferLast;
  assign io_up_b_valid = io_down_b_valid;
  assign io_down_b_ready = io_up_b_ready;
  assign io_up_b_payload_id = io_down_b_payload_id;
  assign io_up_b_payload_resp = io_down_b_payload_resp;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      io_up_aw_fork2_logic_linkEnable_0 <= 1'b1;
      io_up_aw_fork2_logic_linkEnable_1 <= 1'b1;
      onAw_toW_rValidN <= 1'b1;
      onW_awS2m_rValid <= 1'b0;
      onW_commitCmd_rValid <= 1'b0;
      onW_firstCycle <= 1'b1;
      onW_counter <= 2'b00;
    end else begin
      if(onAw_downFork_fire) begin
        io_up_aw_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(onAw_wFork_fire) begin
        io_up_aw_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(io_up_aw_ready) begin
        io_up_aw_fork2_logic_linkEnable_0 <= 1'b1;
        io_up_aw_fork2_logic_linkEnable_1 <= 1'b1;
      end
      if(onAw_toW_valid) begin
        onAw_toW_rValidN <= 1'b0;
      end
      if(onW_awS2m_ready) begin
        onAw_toW_rValidN <= 1'b1;
      end
      if(onW_awS2m_ready) begin
        onW_awS2m_rValid <= onW_awS2m_valid;
      end
      if(onW_commitCmd_ready) begin
        onW_commitCmd_rValid <= onW_commitCmd_valid;
      end
      onW_firstCycle <= 1'b0;
      if(io_up_w_fire) begin
        onW_counter <= onW_counterPlus[1:0];
      end
      if(onW_awS2m_fire) begin
        onW_counter <= onW_awS2m_payload_offset;
      end
    end
  end

  always @(posedge clk) begin
    if(onAw_toW_ready) begin
      onAw_toW_rData_len <= onAw_toW_payload_len;
      onAw_toW_rData_bytePerBeat <= onAw_toW_payload_bytePerBeat;
      onAw_toW_rData_offset <= onAw_toW_payload_offset;
    end
    if(onW_awS2m_ready) begin
      onW_awS2m_rData_len <= onW_awS2m_payload_len;
      onW_awS2m_rData_bytePerBeat <= onW_awS2m_payload_bytePerBeat;
      onW_awS2m_rData_offset <= onW_awS2m_payload_offset;
    end
    if(when_Axi4Compactor_l53) begin
      onW_buffer_0_strb <= 1'b0;
    end
    if(when_Axi4Compactor_l53_1) begin
      onW_buffer_1_strb <= 1'b0;
    end
    if(when_Axi4Compactor_l53_2) begin
      onW_buffer_2_strb <= 1'b0;
    end
    if(when_Axi4Compactor_l53_3) begin
      onW_buffer_3_strb <= 1'b0;
    end
    if(io_up_w_fire) begin
      if(when_Axi4Compactor_l74) begin
        onW_buffer_0_data <= io_up_w_payload_data[7 : 0];
        onW_buffer_0_strb <= io_up_w_payload_strb[0];
      end
      if(when_Axi4Compactor_l74_1) begin
        onW_buffer_1_data <= io_up_w_payload_data[15 : 8];
        onW_buffer_1_strb <= io_up_w_payload_strb[1];
      end
      if(when_Axi4Compactor_l74_2) begin
        onW_buffer_2_data <= io_up_w_payload_data[23 : 16];
        onW_buffer_2_strb <= io_up_w_payload_strb[2];
      end
      if(when_Axi4Compactor_l74_3) begin
        onW_buffer_3_data <= io_up_w_payload_data[31 : 24];
        onW_buffer_3_strb <= io_up_w_payload_strb[3];
      end
      onW_bufferLast <= io_up_w_payload_last;
    end
  end


endmodule

module Axi4WriteOnlyOnePerId (
  input  wire          io_up_aw_valid,
  output wire          io_up_aw_ready,
  input  wire [31:0]   io_up_aw_payload_addr,
  input  wire [3:0]    io_up_aw_payload_id,
  input  wire [3:0]    io_up_aw_payload_region,
  input  wire [7:0]    io_up_aw_payload_len,
  input  wire [2:0]    io_up_aw_payload_size,
  input  wire [1:0]    io_up_aw_payload_burst,
  input  wire [0:0]    io_up_aw_payload_lock,
  input  wire [3:0]    io_up_aw_payload_cache,
  input  wire [3:0]    io_up_aw_payload_qos,
  input  wire [2:0]    io_up_aw_payload_prot,
  input  wire          io_up_w_valid,
  output wire          io_up_w_ready,
  input  wire [31:0]   io_up_w_payload_data,
  input  wire [3:0]    io_up_w_payload_strb,
  input  wire          io_up_w_payload_last,
  output wire          io_up_b_valid,
  input  wire          io_up_b_ready,
  output wire [3:0]    io_up_b_payload_id,
  output wire [1:0]    io_up_b_payload_resp,
  output wire          io_down_aw_valid,
  input  wire          io_down_aw_ready,
  output wire [31:0]   io_down_aw_payload_addr,
  output wire [3:0]    io_down_aw_payload_id,
  output wire [3:0]    io_down_aw_payload_region,
  output wire [7:0]    io_down_aw_payload_len,
  output wire [2:0]    io_down_aw_payload_size,
  output wire [1:0]    io_down_aw_payload_burst,
  output wire [0:0]    io_down_aw_payload_lock,
  output wire [3:0]    io_down_aw_payload_cache,
  output wire [3:0]    io_down_aw_payload_qos,
  output wire [2:0]    io_down_aw_payload_prot,
  output wire          io_down_w_valid,
  input  wire          io_down_w_ready,
  output wire [31:0]   io_down_w_payload_data,
  output wire [3:0]    io_down_w_payload_strb,
  output wire          io_down_w_payload_last,
  input  wire          io_down_b_valid,
  output wire          io_down_b_ready,
  input  wire [3:0]    io_down_b_payload_id,
  input  wire [1:0]    io_down_b_payload_resp,
  input  wire          clk,
  input  wire          reset
);

  reg        [15:0]   pendings_valids;
  wire                onAw_busy;
  wire                _zz_io_up_aw_ready;
  wire                onAw_halted_valid;
  reg                 onAw_halted_ready;
  wire       [31:0]   onAw_halted_payload_addr;
  wire       [3:0]    onAw_halted_payload_id;
  wire       [3:0]    onAw_halted_payload_region;
  wire       [7:0]    onAw_halted_payload_len;
  wire       [2:0]    onAw_halted_payload_size;
  wire       [1:0]    onAw_halted_payload_burst;
  wire       [0:0]    onAw_halted_payload_lock;
  wire       [3:0]    onAw_halted_payload_cache;
  wire       [3:0]    onAw_halted_payload_qos;
  wire       [2:0]    onAw_halted_payload_prot;
  wire                onAw_halted_fire;
  wire                onAw_downFork_valid;
  wire                onAw_downFork_ready;
  wire       [31:0]   onAw_downFork_payload_addr;
  wire       [3:0]    onAw_downFork_payload_id;
  wire       [3:0]    onAw_downFork_payload_region;
  wire       [7:0]    onAw_downFork_payload_len;
  wire       [2:0]    onAw_downFork_payload_size;
  wire       [1:0]    onAw_downFork_payload_burst;
  wire       [0:0]    onAw_downFork_payload_lock;
  wire       [3:0]    onAw_downFork_payload_cache;
  wire       [3:0]    onAw_downFork_payload_qos;
  wire       [2:0]    onAw_downFork_payload_prot;
  wire                onAw_wFork_valid;
  wire                onAw_wFork_ready;
  wire       [31:0]   onAw_wFork_payload_addr;
  wire       [3:0]    onAw_wFork_payload_id;
  wire       [3:0]    onAw_wFork_payload_region;
  wire       [7:0]    onAw_wFork_payload_len;
  wire       [2:0]    onAw_wFork_payload_size;
  wire       [1:0]    onAw_wFork_payload_burst;
  wire       [0:0]    onAw_wFork_payload_lock;
  wire       [3:0]    onAw_wFork_payload_cache;
  wire       [3:0]    onAw_wFork_payload_qos;
  wire       [2:0]    onAw_wFork_payload_prot;
  reg                 onAw_halted_fork2_logic_linkEnable_0;
  reg                 onAw_halted_fork2_logic_linkEnable_1;
  wire                when_Stream_l1084;
  wire                when_Stream_l1084_1;
  wire                onAw_downFork_fire;
  wire                onAw_wFork_fire;
  wire                onAw_toW_valid;
  wire                onAw_toW_ready;
  wire                onAw_toW_s2mPipe_valid;
  reg                 onAw_toW_s2mPipe_ready;
  reg                 onAw_toW_rValidN;
  wire                onW_aw_valid;
  wire                onW_aw_ready;
  reg                 onAw_toW_s2mPipe_rValid;
  wire                when_Stream_l393;
  wire                onW_aw_forkSerial_next_valid;
  wire                onW_aw_forkSerial_next_ready;
  wire                onW_join_valid;
  wire                onW_join_ready;
  wire       [31:0]   onW_join_payload_2_data;
  wire       [3:0]    onW_join_payload_2_strb;
  wire                onW_join_payload_2_last;
  wire                onW_join_fire;
  wire                io_down_b_fire;

  assign onAw_busy = pendings_valids[io_up_aw_payload_id];
  assign _zz_io_up_aw_ready = (! onAw_busy);
  assign onAw_halted_valid = (io_up_aw_valid && _zz_io_up_aw_ready);
  assign io_up_aw_ready = (onAw_halted_ready && _zz_io_up_aw_ready);
  assign onAw_halted_payload_addr = io_up_aw_payload_addr;
  assign onAw_halted_payload_id = io_up_aw_payload_id;
  assign onAw_halted_payload_region = io_up_aw_payload_region;
  assign onAw_halted_payload_len = io_up_aw_payload_len;
  assign onAw_halted_payload_size = io_up_aw_payload_size;
  assign onAw_halted_payload_burst = io_up_aw_payload_burst;
  assign onAw_halted_payload_lock = io_up_aw_payload_lock;
  assign onAw_halted_payload_cache = io_up_aw_payload_cache;
  assign onAw_halted_payload_qos = io_up_aw_payload_qos;
  assign onAw_halted_payload_prot = io_up_aw_payload_prot;
  assign onAw_halted_fire = (onAw_halted_valid && onAw_halted_ready);
  always @(*) begin
    onAw_halted_ready = 1'b1;
    if(when_Stream_l1084) begin
      onAw_halted_ready = 1'b0;
    end
    if(when_Stream_l1084_1) begin
      onAw_halted_ready = 1'b0;
    end
  end

  assign when_Stream_l1084 = ((! onAw_downFork_ready) && onAw_halted_fork2_logic_linkEnable_0);
  assign when_Stream_l1084_1 = ((! onAw_wFork_ready) && onAw_halted_fork2_logic_linkEnable_1);
  assign onAw_downFork_valid = (onAw_halted_valid && onAw_halted_fork2_logic_linkEnable_0);
  assign onAw_downFork_payload_addr = onAw_halted_payload_addr;
  assign onAw_downFork_payload_id = onAw_halted_payload_id;
  assign onAw_downFork_payload_region = onAw_halted_payload_region;
  assign onAw_downFork_payload_len = onAw_halted_payload_len;
  assign onAw_downFork_payload_size = onAw_halted_payload_size;
  assign onAw_downFork_payload_burst = onAw_halted_payload_burst;
  assign onAw_downFork_payload_lock = onAw_halted_payload_lock;
  assign onAw_downFork_payload_cache = onAw_halted_payload_cache;
  assign onAw_downFork_payload_qos = onAw_halted_payload_qos;
  assign onAw_downFork_payload_prot = onAw_halted_payload_prot;
  assign onAw_downFork_fire = (onAw_downFork_valid && onAw_downFork_ready);
  assign onAw_wFork_valid = (onAw_halted_valid && onAw_halted_fork2_logic_linkEnable_1);
  assign onAw_wFork_payload_addr = onAw_halted_payload_addr;
  assign onAw_wFork_payload_id = onAw_halted_payload_id;
  assign onAw_wFork_payload_region = onAw_halted_payload_region;
  assign onAw_wFork_payload_len = onAw_halted_payload_len;
  assign onAw_wFork_payload_size = onAw_halted_payload_size;
  assign onAw_wFork_payload_burst = onAw_halted_payload_burst;
  assign onAw_wFork_payload_lock = onAw_halted_payload_lock;
  assign onAw_wFork_payload_cache = onAw_halted_payload_cache;
  assign onAw_wFork_payload_qos = onAw_halted_payload_qos;
  assign onAw_wFork_payload_prot = onAw_halted_payload_prot;
  assign onAw_wFork_fire = (onAw_wFork_valid && onAw_wFork_ready);
  assign io_down_aw_valid = onAw_downFork_valid;
  assign onAw_downFork_ready = io_down_aw_ready;
  assign io_down_aw_payload_addr = onAw_downFork_payload_addr;
  assign io_down_aw_payload_id = onAw_downFork_payload_id;
  assign io_down_aw_payload_region = onAw_downFork_payload_region;
  assign io_down_aw_payload_len = onAw_downFork_payload_len;
  assign io_down_aw_payload_size = onAw_downFork_payload_size;
  assign io_down_aw_payload_burst = onAw_downFork_payload_burst;
  assign io_down_aw_payload_lock = onAw_downFork_payload_lock;
  assign io_down_aw_payload_cache = onAw_downFork_payload_cache;
  assign io_down_aw_payload_qos = onAw_downFork_payload_qos;
  assign io_down_aw_payload_prot = onAw_downFork_payload_prot;
  assign onAw_toW_valid = onAw_wFork_valid;
  assign onAw_wFork_ready = onAw_toW_ready;
  assign onAw_toW_ready = onAw_toW_rValidN;
  assign onAw_toW_s2mPipe_valid = (onAw_toW_valid || (! onAw_toW_rValidN));
  always @(*) begin
    onAw_toW_s2mPipe_ready = onW_aw_ready;
    if(when_Stream_l393) begin
      onAw_toW_s2mPipe_ready = 1'b1;
    end
  end

  assign when_Stream_l393 = (! onW_aw_valid);
  assign onW_aw_valid = onAw_toW_s2mPipe_rValid;
  assign onW_aw_forkSerial_next_valid = onW_aw_valid;
  assign onW_aw_ready = (onW_aw_forkSerial_next_ready && io_up_w_payload_last);
  assign onW_join_valid = (onW_aw_forkSerial_next_valid && io_up_w_valid);
  assign onW_join_fire = (onW_join_valid && onW_join_ready);
  assign onW_aw_forkSerial_next_ready = onW_join_fire;
  assign io_up_w_ready = onW_join_fire;
  assign onW_join_payload_2_data = io_up_w_payload_data;
  assign onW_join_payload_2_strb = io_up_w_payload_strb;
  assign onW_join_payload_2_last = io_up_w_payload_last;
  assign io_down_w_valid = onW_join_valid;
  assign onW_join_ready = io_down_w_ready;
  assign io_down_w_payload_data = io_up_w_payload_data;
  assign io_down_w_payload_strb = io_up_w_payload_strb;
  assign io_down_w_payload_last = io_up_w_payload_last;
  assign io_up_b_valid = io_down_b_valid;
  assign io_down_b_ready = io_up_b_ready;
  assign io_up_b_payload_id = io_down_b_payload_id;
  assign io_up_b_payload_resp = io_down_b_payload_resp;
  assign io_down_b_fire = (io_down_b_valid && io_down_b_ready);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      pendings_valids <= 16'h0;
      onAw_halted_fork2_logic_linkEnable_0 <= 1'b1;
      onAw_halted_fork2_logic_linkEnable_1 <= 1'b1;
      onAw_toW_rValidN <= 1'b1;
      onAw_toW_s2mPipe_rValid <= 1'b0;
    end else begin
      if(onAw_halted_fire) begin
        pendings_valids[io_up_aw_payload_id] <= 1'b1;
      end
      if(onAw_downFork_fire) begin
        onAw_halted_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(onAw_wFork_fire) begin
        onAw_halted_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(onAw_halted_ready) begin
        onAw_halted_fork2_logic_linkEnable_0 <= 1'b1;
        onAw_halted_fork2_logic_linkEnable_1 <= 1'b1;
      end
      if(onAw_toW_valid) begin
        onAw_toW_rValidN <= 1'b0;
      end
      if(onAw_toW_s2mPipe_ready) begin
        onAw_toW_rValidN <= 1'b1;
      end
      if(onAw_toW_s2mPipe_ready) begin
        onAw_toW_s2mPipe_rValid <= onAw_toW_s2mPipe_valid;
      end
      if(io_down_b_fire) begin
        pendings_valids[io_down_b_payload_id] <= 1'b0;
      end
    end
  end


endmodule

module Axi4ReadOnlyToTilelink (
  input  wire          io_up_ar_valid,
  output wire          io_up_ar_ready,
  input  wire [31:0]   io_up_ar_payload_addr,
  input  wire [1:0]    io_up_ar_payload_id,
  input  wire [3:0]    io_up_ar_payload_region,
  input  wire [7:0]    io_up_ar_payload_len,
  input  wire [2:0]    io_up_ar_payload_size,
  input  wire [1:0]    io_up_ar_payload_burst,
  input  wire [0:0]    io_up_ar_payload_lock,
  input  wire [3:0]    io_up_ar_payload_cache,
  input  wire [3:0]    io_up_ar_payload_qos,
  input  wire [2:0]    io_up_ar_payload_prot,
  output wire          io_up_r_valid,
  input  wire          io_up_r_ready,
  output wire [31:0]   io_up_r_payload_data,
  output wire [1:0]    io_up_r_payload_id,
  output reg  [1:0]    io_up_r_payload_resp,
  output wire          io_up_r_payload_last,
  output wire          io_down_a_valid,
  input  wire          io_down_a_ready,
  output wire [2:0]    io_down_a_payload_opcode,
  output wire [2:0]    io_down_a_payload_param,
  output wire [1:0]    io_down_a_payload_source,
  output wire [31:0]   io_down_a_payload_address,
  output wire [2:0]    io_down_a_payload_size,
  input  wire          io_down_d_valid,
  output wire          io_down_d_ready,
  input  wire [2:0]    io_down_d_payload_opcode,
  input  wire [2:0]    io_down_d_payload_param,
  input  wire [1:0]    io_down_d_payload_source,
  input  wire [2:0]    io_down_d_payload_size,
  input  wire          io_down_d_payload_denied,
  input  wire [31:0]   io_down_d_payload_data,
  input  wire          io_down_d_payload_corrupt,
  input  wire          clk,
  input  wire          reset
);
  localparam A_PUT_FULL_DATA = 3'd0;
  localparam A_PUT_PARTIAL_DATA = 3'd1;
  localparam A_GET = 3'd4;
  localparam A_ACQUIRE_BLOCK = 3'd6;
  localparam A_ACQUIRE_PERM = 3'd7;
  localparam D_ACCESS_ACK = 3'd0;
  localparam D_ACCESS_ACK_DATA = 3'd1;
  localparam D_GRANT = 3'd4;
  localparam D_GRANT_DATA = 3'd5;
  localparam D_RELEASE_ACK = 3'd6;

  wire       [7:0]    _zz__zz_a_lenToSize_2;
  wire       [3:0]    _zz_io_down_a_payload_size;
  wire       [3:0]    _zz_io_down_a_payload_size_1;
  reg        [2:0]    _zz_io_down_d_tracker_last;
  wire       [7:0]    _zz_a_lenToSize;
  reg        [7:0]    _zz_a_lenToSize_1;
  wire       [7:0]    _zz_a_lenToSize_2;
  reg        [7:0]    _zz_a_lenToSize_3;
  wire       [8:0]    _zz_a_lenToSize_4;
  wire                _zz_a_lenToSize_5;
  wire                _zz_a_lenToSize_6;
  wire                _zz_a_lenToSize_7;
  wire                _zz_a_lenToSize_8;
  wire                _zz_a_lenToSize_9;
  wire                _zz_a_lenToSize_10;
  wire                _zz_a_lenToSize_11;
  wire                _zz_a_lenToSize_12;
  wire       [3:0]    a_lenToSize;
  reg        [2:0]    io_down_d_tracker_beat;
  wire                io_down_d_tracker_last;
  wire                io_down_d_fire;
  `ifndef SYNTHESIS
  reg [127:0] io_down_a_payload_opcode_string;
  reg [119:0] io_down_d_payload_opcode_string;
  `endif


  assign _zz__zz_a_lenToSize_2 = (_zz_a_lenToSize_1 - 8'h01);
  assign _zz_io_down_a_payload_size = (a_lenToSize + _zz_io_down_a_payload_size_1);
  assign _zz_io_down_a_payload_size_1 = {1'd0, io_up_ar_payload_size};
  always @(*) begin
    case(io_down_d_payload_size)
      3'b000 : _zz_io_down_d_tracker_last = 3'b000;
      3'b001 : _zz_io_down_d_tracker_last = 3'b000;
      3'b010 : _zz_io_down_d_tracker_last = 3'b000;
      3'b011 : _zz_io_down_d_tracker_last = 3'b001;
      3'b100 : _zz_io_down_d_tracker_last = 3'b011;
      default : _zz_io_down_d_tracker_last = 3'b111;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_down_a_payload_opcode)
      A_PUT_FULL_DATA : io_down_a_payload_opcode_string = "PUT_FULL_DATA   ";
      A_PUT_PARTIAL_DATA : io_down_a_payload_opcode_string = "PUT_PARTIAL_DATA";
      A_GET : io_down_a_payload_opcode_string = "GET             ";
      A_ACQUIRE_BLOCK : io_down_a_payload_opcode_string = "ACQUIRE_BLOCK   ";
      A_ACQUIRE_PERM : io_down_a_payload_opcode_string = "ACQUIRE_PERM    ";
      default : io_down_a_payload_opcode_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(io_down_d_payload_opcode)
      D_ACCESS_ACK : io_down_d_payload_opcode_string = "ACCESS_ACK     ";
      D_ACCESS_ACK_DATA : io_down_d_payload_opcode_string = "ACCESS_ACK_DATA";
      D_GRANT : io_down_d_payload_opcode_string = "GRANT          ";
      D_GRANT_DATA : io_down_d_payload_opcode_string = "GRANT_DATA     ";
      D_RELEASE_ACK : io_down_d_payload_opcode_string = "RELEASE_ACK    ";
      default : io_down_d_payload_opcode_string = "???????????????";
    endcase
  end
  `endif

  assign io_down_a_valid = io_up_ar_valid;
  assign io_up_ar_ready = io_down_a_ready;
  assign _zz_a_lenToSize = io_up_ar_payload_len;
  always @(*) begin
    _zz_a_lenToSize_1[0] = _zz_a_lenToSize[7];
    _zz_a_lenToSize_1[1] = _zz_a_lenToSize[6];
    _zz_a_lenToSize_1[2] = _zz_a_lenToSize[5];
    _zz_a_lenToSize_1[3] = _zz_a_lenToSize[4];
    _zz_a_lenToSize_1[4] = _zz_a_lenToSize[3];
    _zz_a_lenToSize_1[5] = _zz_a_lenToSize[2];
    _zz_a_lenToSize_1[6] = _zz_a_lenToSize[1];
    _zz_a_lenToSize_1[7] = _zz_a_lenToSize[0];
  end

  assign _zz_a_lenToSize_2 = (_zz_a_lenToSize_1 & (~ _zz__zz_a_lenToSize_2));
  always @(*) begin
    _zz_a_lenToSize_3[0] = _zz_a_lenToSize_2[7];
    _zz_a_lenToSize_3[1] = _zz_a_lenToSize_2[6];
    _zz_a_lenToSize_3[2] = _zz_a_lenToSize_2[5];
    _zz_a_lenToSize_3[3] = _zz_a_lenToSize_2[4];
    _zz_a_lenToSize_3[4] = _zz_a_lenToSize_2[3];
    _zz_a_lenToSize_3[5] = _zz_a_lenToSize_2[2];
    _zz_a_lenToSize_3[6] = _zz_a_lenToSize_2[1];
    _zz_a_lenToSize_3[7] = _zz_a_lenToSize_2[0];
  end

  assign _zz_a_lenToSize_4 = {_zz_a_lenToSize_3,1'b0};
  assign _zz_a_lenToSize_5 = _zz_a_lenToSize_4[3];
  assign _zz_a_lenToSize_6 = _zz_a_lenToSize_4[5];
  assign _zz_a_lenToSize_7 = _zz_a_lenToSize_4[6];
  assign _zz_a_lenToSize_8 = _zz_a_lenToSize_4[7];
  assign _zz_a_lenToSize_9 = _zz_a_lenToSize_4[8];
  assign _zz_a_lenToSize_10 = (((_zz_a_lenToSize_4[1] || _zz_a_lenToSize_5) || _zz_a_lenToSize_6) || _zz_a_lenToSize_8);
  assign _zz_a_lenToSize_11 = (((_zz_a_lenToSize_4[2] || _zz_a_lenToSize_5) || _zz_a_lenToSize_7) || _zz_a_lenToSize_8);
  assign _zz_a_lenToSize_12 = (((_zz_a_lenToSize_4[4] || _zz_a_lenToSize_6) || _zz_a_lenToSize_7) || _zz_a_lenToSize_8);
  assign a_lenToSize = {_zz_a_lenToSize_9,{_zz_a_lenToSize_12,{_zz_a_lenToSize_11,_zz_a_lenToSize_10}}};
  assign io_down_a_payload_opcode = A_GET;
  assign io_down_a_payload_param = 3'b000;
  assign io_down_a_payload_source = io_up_ar_payload_id;
  assign io_down_a_payload_address = io_up_ar_payload_addr;
  assign io_down_a_payload_size = _zz_io_down_a_payload_size[2:0];
  assign io_up_r_valid = io_down_d_valid;
  assign io_down_d_ready = io_up_r_ready;
  assign io_up_r_payload_id = io_down_d_payload_source;
  assign io_up_r_payload_data = io_down_d_payload_data;
  assign io_down_d_tracker_last = ((! ((1'b0 || (D_ACCESS_ACK_DATA == io_down_d_payload_opcode)) || (D_GRANT_DATA == io_down_d_payload_opcode))) || (io_down_d_tracker_beat == _zz_io_down_d_tracker_last));
  assign io_down_d_fire = (io_down_d_valid && io_down_d_ready);
  assign io_up_r_payload_last = io_down_d_tracker_last;
  always @(*) begin
    io_up_r_payload_resp = 2'b00;
    if(io_down_d_payload_denied) begin
      io_up_r_payload_resp = 2'b10;
    end
  end

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      io_down_d_tracker_beat <= 3'b000;
    end else begin
      if(io_down_d_fire) begin
        io_down_d_tracker_beat <= (io_down_d_tracker_beat + 3'b001);
        if(io_down_d_tracker_last) begin
          io_down_d_tracker_beat <= 3'b000;
        end
      end
    end
  end


endmodule

module Axi4ReadOnlyAligner (
  input  wire          io_up_ar_valid,
  output wire          io_up_ar_ready,
  input  wire [31:0]   io_up_ar_payload_addr,
  input  wire [3:0]    io_up_ar_payload_id,
  input  wire [3:0]    io_up_ar_payload_region,
  input  wire [7:0]    io_up_ar_payload_len,
  input  wire [2:0]    io_up_ar_payload_size,
  input  wire [1:0]    io_up_ar_payload_burst,
  input  wire [0:0]    io_up_ar_payload_lock,
  input  wire [3:0]    io_up_ar_payload_cache,
  input  wire [3:0]    io_up_ar_payload_qos,
  input  wire [2:0]    io_up_ar_payload_prot,
  output wire          io_up_r_valid,
  input  wire          io_up_r_ready,
  output wire [31:0]   io_up_r_payload_data,
  output wire [3:0]    io_up_r_payload_id,
  output reg  [1:0]    io_up_r_payload_resp,
  output wire          io_up_r_payload_last,
  output wire          io_down_ar_valid,
  input  wire          io_down_ar_ready,
  output reg  [31:0]   io_down_ar_payload_addr,
  output wire [1:0]    io_down_ar_payload_id,
  output wire [3:0]    io_down_ar_payload_region,
  output wire [7:0]    io_down_ar_payload_len,
  output reg  [2:0]    io_down_ar_payload_size,
  output wire [1:0]    io_down_ar_payload_burst,
  output wire [0:0]    io_down_ar_payload_lock,
  output wire [3:0]    io_down_ar_payload_cache,
  output wire [3:0]    io_down_ar_payload_qos,
  output wire [2:0]    io_down_ar_payload_prot,
  input  wire          io_down_r_valid,
  output wire          io_down_r_ready,
  input  wire [31:0]   io_down_r_payload_data,
  input  wire [1:0]    io_down_r_payload_id,
  input  wire [1:0]    io_down_r_payload_resp,
  input  wire          io_down_r_payload_last,
  input  wire          clk,
  input  wire          reset
);

  reg        [10:0]   context_mem_spinal_port1;
  reg        [31:0]   rData_mem_spinal_port1;
  wire       [10:0]   _zz_context_mem_port;
  wire       [31:0]   _zz_frontend_split_spliter_boundedEnd;
  wire       [31:0]   _zz_frontend_split_spliter_boundedEnd_1;
  wire       [9:0]    _zz_frontend_split_spliter_boundedEnd_2;
  wire       [4:0]    _zz_frontend_split_aligner_CHUNK_START;
  wire       [4:0]    _zz_frontend_split_aligner_CHUNK_END;
  wire       [4:0]    _zz_context_write_payload_data_header;
  wire       [4:0]    _zz_context_write_payload_data_header_1;
  reg        [1:0]    _zz_frontend_allocateSlot_smallSize;
  wire       [1:0]    _zz_frontend_allocateSlot_smallSize_1;
  reg                 _zz_upR_handle_done_1;
  wire       [1:0]    _zz_upR_handle_done_2;
  reg                 _zz_upR_handle_error;
  wire       [1:0]    _zz_upR_handle_error_1;
  wire       [2:0]    _zz_rData_read_cmd_payload;
  reg                 upR_rsp_ready;
  reg                 upR_rsp_handle_ERRORED;
  reg                 upR_rsp_handle_CTX_last;
  reg        [3:0]    upR_rsp_handle_CTX_id;
  reg        [2:0]    upR_rsp_handle_CTX_header;
  reg        [2:0]    upR_rsp_handle_CTX_ups;
  wire                upR_handle_isForked;
  reg                 _zz_upR_handle_forkRequest_Axi4Aligner_l422;
  wire                upR_handle_ERRORED;
  reg                 upR_handle_ready;
  wire                upR_handle_CTX_last;
  wire       [3:0]    upR_handle_CTX_id;
  wire       [2:0]    upR_handle_CTX_header;
  wire       [2:0]    upR_handle_CTX_ups;
  wire                upR_fetch_ready;
  reg        [4:0]    frontend_allocateSlot_split_aligner_CHUNK_END;
  reg        [2:0]    frontend_allocateSlot_split_aligner_LEN;
  reg        [6:0]    frontend_allocateSlot_split_spliter_BOUNDED_BLOCK;
  reg                 frontend_allocateSlot_ready;
  reg        [2:0]    frontend_allocateSlot_split_spliter_CHUNKS_WORDS;
  reg                 frontend_allocateSlot_split_spliter_FIRST;
  reg        [4:0]    frontend_allocateSlot_split_aligner_CHUNK_START;
  reg        [31:0]   frontend_allocateSlot_bufferize_AR_addr;
  reg        [3:0]    frontend_allocateSlot_bufferize_AR_id;
  reg        [3:0]    frontend_allocateSlot_bufferize_AR_region;
  reg        [7:0]    frontend_allocateSlot_bufferize_AR_len;
  reg        [2:0]    frontend_allocateSlot_bufferize_AR_size;
  reg        [1:0]    frontend_allocateSlot_bufferize_AR_burst;
  reg        [0:0]    frontend_allocateSlot_bufferize_AR_lock;
  reg        [3:0]    frontend_allocateSlot_bufferize_AR_cache;
  reg        [3:0]    frontend_allocateSlot_bufferize_AR_qos;
  reg        [2:0]    frontend_allocateSlot_bufferize_AR_prot;
  reg                 frontend_allocateSlot_split_spliter_LAST;
  wire       [2:0]    frontend_split_aligner_LEN;
  wire       [4:0]    frontend_split_aligner_CHUNK_END;
  wire       [4:0]    frontend_split_aligner_CHUNK_START;
  wire                frontend_split_isForked;
  wire       [2:0]    frontend_split_spliter_CHUNKS_WORDS;
  wire       [6:0]    frontend_split_spliter_BOUNDED_BLOCK;
  wire                frontend_split_spliter_FIRST;
  wire                frontend_split_spliter_LAST;
  reg        [31:0]   frontend_split_bufferize_AR_addr;
  reg        [3:0]    frontend_split_bufferize_AR_id;
  reg        [3:0]    frontend_split_bufferize_AR_region;
  reg        [7:0]    frontend_split_bufferize_AR_len;
  reg        [2:0]    frontend_split_bufferize_AR_size;
  reg        [1:0]    frontend_split_bufferize_AR_burst;
  reg        [0:0]    frontend_split_bufferize_AR_lock;
  reg        [3:0]    frontend_split_bufferize_AR_cache;
  reg        [3:0]    frontend_split_bufferize_AR_qos;
  reg        [2:0]    frontend_split_bufferize_AR_prot;
  wire       [31:0]   frontend_bufferize_AR_addr;
  wire       [3:0]    frontend_bufferize_AR_id;
  wire       [3:0]    frontend_bufferize_AR_region;
  wire       [7:0]    frontend_bufferize_AR_len;
  wire       [2:0]    frontend_bufferize_AR_size;
  wire       [1:0]    frontend_bufferize_AR_burst;
  wire       [0:0]    frontend_bufferize_AR_lock;
  wire       [3:0]    frontend_bufferize_AR_cache;
  wire       [3:0]    frontend_bufferize_AR_qos;
  wire       [2:0]    frontend_bufferize_AR_prot;
  wire                frontend_bufferize_ready;
  reg                 _zz_1;
  reg                 _zz_2;
  reg        [2:0]    ptr_cmd;
  reg        [2:0]    ptr_fetch;
  reg        [2:0]    ptr_rsp;
  wire                ptr_full;
  reg                 slots_0_done;
  reg                 slots_0_error;
  reg                 slots_1_done;
  reg                 slots_1_error;
  reg                 slots_2_done;
  reg                 slots_2_error;
  reg                 slots_3_done;
  reg                 slots_3_error;
  reg                 context_write_valid;
  wire       [1:0]    context_write_payload_address;
  wire                context_write_payload_data_last;
  wire       [3:0]    context_write_payload_data_id;
  wire       [2:0]    context_write_payload_data_header;
  wire       [2:0]    context_write_payload_data_ups;
  reg                 context_read_cmd_valid;
  wire       [1:0]    context_read_cmd_payload;
  wire                context_read_rsp_last;
  wire       [3:0]    context_read_rsp_id;
  wire       [2:0]    context_read_rsp_header;
  wire       [2:0]    context_read_rsp_ups;
  wire       [10:0]   _zz_context_read_rsp_last;
  reg                 rData_write_valid;
  wire       [4:0]    rData_write_payload_address;
  wire       [31:0]   rData_write_payload_data;
  reg                 rData_read_cmd_valid;
  wire       [4:0]    rData_read_cmd_payload;
  wire       [31:0]   rData_read_rsp;
  wire                frontend_bufferize_valid;
  reg                 frontend_split_valid;
  wire                _zz_frontend_split_isForked;
  wire       [11:0]   frontend_split_spliter_boundedStart;
  wire       [11:0]   frontend_split_spliter_boundedEnd;
  wire       [6:0]    frontend_split_spliter_blockStart;
  wire       [6:0]    frontend_split_spliter_blockEnd;
  wire       [6:0]    frontend_split_spliter_blockCount;
  reg        [6:0]    frontend_split_spliter_blockCounter;
  wire       [2:0]    frontend_split_spliter_chunkWordStart;
  wire       [2:0]    frontend_split_spliter_chunkWordEnd;
  wire                frontend_split_forkRequest_Axi4Aligner_l320;
  reg        [1:0]    frontend_split_aligner_sizeToMask;
  wire       [2:0]    _zz_frontend_split_aligner_mask;
  reg        [2:0]    _zz_frontend_split_aligner_mask_1;
  wire       [4:0]    frontend_split_aligner_mask;
  reg                 frontend_allocateSlot_valid;
  wire                frontend_allocateSlot_haltRequest_Axi4Aligner_l342;
  wire                frontend_allocateSlot_isFireing;
  wire       [1:0]    switch_Utils_l1436;
  wire                frontend_allocateSlot_haltRequest_Axi4Aligner_l359;
  wire       [4:0]    frontend_allocateSlot_bytes;
  wire       [1:0]    frontend_allocateSlot_smallSize;
  wire                when_Axi4Aligner_l368;
  reg                 frontend_split_ready_output;
  reg                 frontend_split_ready;
  reg                 frontend_bufferize_ready_output;
  wire                when_Pipeline_l285;
  wire                when_Pipeline_l278;
  wire                when_Connection_l74;
  wire                when_Connection_l74_1;
  reg        [2:0]    downR_counter;
  wire                io_down_r_fire;
  wire                upR_fetch_valid;
  wire                upR_fetch_isFireing;
  reg                 upR_handle_valid;
  reg                 _zz_upR_handle_isForked;
  wire       [2:0]    _zz_upR_handle_done;
  wire                upR_handle_done;
  wire                upR_handle_error;
  reg                 upR_handle_errorAcc;
  wire                upR_handle_isFireing;
  wire                when_Axi4Aligner_l411;
  reg        [2:0]    upR_handle_counter;
  wire                upR_handle_CHUNK_LAST;
  wire                upR_handle_haltRequest_Axi4Aligner_l416;
  wire                when_Axi4Aligner_l420;
  wire                when_Axi4Aligner_l421;
  wire                upR_handle_forkRequest_Axi4Aligner_l422;
  reg                 upR_rsp_valid;
  wire                io_up_r_isStall;
  wire                upR_rsp_haltRequest_Axi4Aligner_l438;
  reg                 upR_handle_ready_output;
  reg                 upR_fetch_ready_output;
  wire                when_Pipeline_l278_1;
  wire                when_Pipeline_l285_1;
  wire                when_Pipeline_l278_2;
  wire                when_Connection_l74_2;
  wire                when_Connection_l74_3;
  reg [10:0] context_mem [0:3];
  reg [31:0] rData_mem [0:31];

  assign _zz_frontend_split_spliter_boundedEnd = (frontend_split_bufferize_AR_addr + _zz_frontend_split_spliter_boundedEnd_1);
  assign _zz_frontend_split_spliter_boundedEnd_2 = ({2'd0,frontend_split_bufferize_AR_len} <<< 2'd2);
  assign _zz_frontend_split_spliter_boundedEnd_1 = {22'd0, _zz_frontend_split_spliter_boundedEnd_2};
  assign _zz_frontend_split_aligner_CHUNK_START = frontend_split_spliter_boundedStart[4:0];
  assign _zz_frontend_split_aligner_CHUNK_END = frontend_split_spliter_boundedEnd[4:0];
  assign _zz_context_write_payload_data_header = (_zz_context_write_payload_data_header_1 - frontend_allocateSlot_split_aligner_CHUNK_START);
  assign _zz_context_write_payload_data_header_1 = frontend_allocateSlot_bufferize_AR_addr[4:0];
  assign _zz_upR_handle_done_2 = _zz_upR_handle_done[1:0];
  assign _zz_upR_handle_error_1 = _zz_upR_handle_done[1:0];
  assign _zz_rData_read_cmd_payload = (upR_handle_CTX_header + upR_handle_counter);
  assign _zz_context_mem_port = {context_write_payload_data_ups,{context_write_payload_data_header,{context_write_payload_data_id,context_write_payload_data_last}}};
  assign _zz_frontend_allocateSlot_smallSize_1 = frontend_allocateSlot_bytes[1 : 0];
  always @(posedge clk) begin
    if(_zz_2) begin
      context_mem[context_write_payload_address] <= _zz_context_mem_port;
    end
  end

  always @(posedge clk) begin
    if(context_read_cmd_valid) begin
      context_mem_spinal_port1 <= context_mem[context_read_cmd_payload];
    end
  end

  always @(posedge clk) begin
    if(_zz_1) begin
      rData_mem[rData_write_payload_address] <= rData_write_payload_data;
    end
  end

  always @(posedge clk) begin
    if(rData_read_cmd_valid) begin
      rData_mem_spinal_port1 <= rData_mem[rData_read_cmd_payload];
    end
  end

  always @(*) begin
    case(_zz_frontend_allocateSlot_smallSize_1)
      2'b00 : _zz_frontend_allocateSlot_smallSize = 2'b00;
      2'b01 : _zz_frontend_allocateSlot_smallSize = 2'b01;
      2'b10 : _zz_frontend_allocateSlot_smallSize = 2'b10;
      default : _zz_frontend_allocateSlot_smallSize = 2'b10;
    endcase
  end

  always @(*) begin
    case(_zz_upR_handle_done_2)
      2'b00 : _zz_upR_handle_done_1 = slots_0_done;
      2'b01 : _zz_upR_handle_done_1 = slots_1_done;
      2'b10 : _zz_upR_handle_done_1 = slots_2_done;
      default : _zz_upR_handle_done_1 = slots_3_done;
    endcase
  end

  always @(*) begin
    case(_zz_upR_handle_error_1)
      2'b00 : _zz_upR_handle_error = slots_0_error;
      2'b01 : _zz_upR_handle_error = slots_1_error;
      2'b10 : _zz_upR_handle_error = slots_2_error;
      default : _zz_upR_handle_error = slots_3_error;
    endcase
  end

  always @(*) begin
    _zz_upR_handle_forkRequest_Axi4Aligner_l422 = 1'b0;
    if(when_Axi4Aligner_l420) begin
      if(when_Axi4Aligner_l421) begin
        _zz_upR_handle_forkRequest_Axi4Aligner_l422 = 1'b1;
      end
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(rData_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  always @(*) begin
    _zz_2 = 1'b0;
    if(context_write_valid) begin
      _zz_2 = 1'b1;
    end
  end

  assign ptr_full = (((ptr_cmd ^ ptr_rsp) ^ 3'b100) == 3'b000);
  assign _zz_context_read_rsp_last = context_mem_spinal_port1;
  assign context_read_rsp_last = _zz_context_read_rsp_last[0];
  assign context_read_rsp_id = _zz_context_read_rsp_last[4 : 1];
  assign context_read_rsp_header = _zz_context_read_rsp_last[7 : 5];
  assign context_read_rsp_ups = _zz_context_read_rsp_last[10 : 8];
  assign rData_read_rsp = rData_mem_spinal_port1;
  assign frontend_bufferize_valid = io_up_ar_valid;
  assign io_up_ar_ready = frontend_bufferize_ready;
  assign frontend_bufferize_AR_addr = io_up_ar_payload_addr;
  assign frontend_bufferize_AR_id = io_up_ar_payload_id;
  assign frontend_bufferize_AR_region = io_up_ar_payload_region;
  assign frontend_bufferize_AR_len = io_up_ar_payload_len;
  assign frontend_bufferize_AR_size = io_up_ar_payload_size;
  assign frontend_bufferize_AR_burst = io_up_ar_payload_burst;
  assign frontend_bufferize_AR_lock = io_up_ar_payload_lock;
  assign frontend_bufferize_AR_cache = io_up_ar_payload_cache;
  assign frontend_bufferize_AR_qos = io_up_ar_payload_qos;
  assign frontend_bufferize_AR_prot = io_up_ar_payload_prot;
  assign frontend_split_spliter_boundedStart = frontend_split_bufferize_AR_addr[11:0];
  assign frontend_split_spliter_boundedEnd = _zz_frontend_split_spliter_boundedEnd[11:0];
  assign frontend_split_spliter_blockStart = (frontend_split_spliter_boundedStart >>> 3'd5);
  assign frontend_split_spliter_blockEnd = (frontend_split_spliter_boundedEnd >>> 3'd5);
  assign frontend_split_spliter_blockCount = (frontend_split_spliter_blockEnd - frontend_split_spliter_blockStart);
  assign frontend_split_spliter_LAST = (frontend_split_spliter_blockCounter == frontend_split_spliter_blockCount);
  assign frontend_split_spliter_FIRST = (frontend_split_spliter_blockCounter == 7'h0);
  assign frontend_split_spliter_BOUNDED_BLOCK = (frontend_split_spliter_blockStart + frontend_split_spliter_blockCounter);
  assign frontend_split_spliter_chunkWordStart = (frontend_split_spliter_FIRST ? frontend_split_spliter_boundedStart[4 : 2] : 3'b000);
  assign frontend_split_spliter_chunkWordEnd = (frontend_split_spliter_LAST ? frontend_split_spliter_boundedEnd[4 : 2] : 3'b111);
  assign frontend_split_spliter_CHUNKS_WORDS = (frontend_split_spliter_chunkWordEnd - frontend_split_spliter_chunkWordStart);
  assign frontend_split_forkRequest_Axi4Aligner_l320 = (! frontend_split_spliter_LAST);
  always @(*) begin
    frontend_split_aligner_sizeToMask = 2'bxx;
    case(frontend_split_bufferize_AR_size)
      3'b000 : begin
        frontend_split_aligner_sizeToMask = 2'b00;
      end
      3'b001 : begin
        frontend_split_aligner_sizeToMask = 2'b01;
      end
      3'b010 : begin
        frontend_split_aligner_sizeToMask = 2'b11;
      end
      default : begin
      end
    endcase
  end

  assign _zz_frontend_split_aligner_mask = (frontend_split_spliter_chunkWordStart ^ frontend_split_spliter_chunkWordEnd);
  always @(*) begin
    _zz_frontend_split_aligner_mask_1[0] = (|_zz_frontend_split_aligner_mask[2 : 0]);
    _zz_frontend_split_aligner_mask_1[1] = (|_zz_frontend_split_aligner_mask[2 : 1]);
    _zz_frontend_split_aligner_mask_1[2] = (|_zz_frontend_split_aligner_mask[2 : 2]);
  end

  assign frontend_split_aligner_mask = {_zz_frontend_split_aligner_mask_1,((frontend_split_bufferize_AR_len != 8'h0) ? 2'b11 : frontend_split_aligner_sizeToMask)};
  assign frontend_split_aligner_CHUNK_START = (frontend_split_spliter_FIRST ? (_zz_frontend_split_aligner_CHUNK_START & (~ frontend_split_aligner_mask)) : 5'h0);
  assign frontend_split_aligner_CHUNK_END = ((! frontend_split_spliter_LAST) ? 5'h1f : (_zz_frontend_split_aligner_CHUNK_END | frontend_split_aligner_mask));
  assign frontend_split_aligner_LEN = (frontend_split_aligner_CHUNK_END[4 : 2] - frontend_split_aligner_CHUNK_START[4 : 2]);
  assign frontend_allocateSlot_haltRequest_Axi4Aligner_l342 = ptr_full;
  always @(*) begin
    context_write_valid = 1'b0;
    if(frontend_allocateSlot_isFireing) begin
      context_write_valid = 1'b1;
    end
  end

  assign context_write_payload_address = ptr_cmd[1:0];
  assign context_write_payload_data_last = frontend_allocateSlot_split_spliter_LAST;
  assign context_write_payload_data_id = frontend_allocateSlot_bufferize_AR_id;
  assign context_write_payload_data_header = (frontend_allocateSlot_split_spliter_FIRST ? _zz_context_write_payload_data_header[4 : 2] : 3'b000);
  assign context_write_payload_data_ups = frontend_allocateSlot_split_spliter_CHUNKS_WORDS;
  assign frontend_allocateSlot_isFireing = (frontend_allocateSlot_valid && frontend_allocateSlot_ready);
  assign switch_Utils_l1436 = ptr_cmd[1:0];
  assign frontend_allocateSlot_haltRequest_Axi4Aligner_l359 = (! io_down_ar_ready);
  assign io_down_ar_valid = (frontend_allocateSlot_valid && (! ptr_full));
  always @(*) begin
    io_down_ar_payload_addr = frontend_allocateSlot_bufferize_AR_addr;
    io_down_ar_payload_addr[4 : 0] = frontend_allocateSlot_split_aligner_CHUNK_START;
    io_down_ar_payload_addr[11 : 5] = frontend_allocateSlot_split_spliter_BOUNDED_BLOCK;
  end

  assign io_down_ar_payload_region = frontend_allocateSlot_bufferize_AR_region;
  always @(*) begin
    io_down_ar_payload_size = frontend_allocateSlot_bufferize_AR_size;
    if(when_Axi4Aligner_l368) begin
      io_down_ar_payload_size = {1'd0, frontend_allocateSlot_smallSize};
    end
  end

  assign io_down_ar_payload_burst = frontend_allocateSlot_bufferize_AR_burst;
  assign io_down_ar_payload_lock = frontend_allocateSlot_bufferize_AR_lock;
  assign io_down_ar_payload_cache = frontend_allocateSlot_bufferize_AR_cache;
  assign io_down_ar_payload_qos = frontend_allocateSlot_bufferize_AR_qos;
  assign io_down_ar_payload_prot = frontend_allocateSlot_bufferize_AR_prot;
  assign io_down_ar_payload_len = {5'd0, frontend_allocateSlot_split_aligner_LEN};
  assign io_down_ar_payload_id = ptr_cmd[1:0];
  assign frontend_allocateSlot_bytes = (frontend_allocateSlot_split_aligner_CHUNK_END - frontend_allocateSlot_split_aligner_CHUNK_START);
  assign frontend_allocateSlot_smallSize = _zz_frontend_allocateSlot_smallSize;
  assign when_Axi4Aligner_l368 = (frontend_allocateSlot_split_aligner_LEN == 3'b000);
  assign frontend_split_isForked = (_zz_frontend_split_isForked && frontend_split_ready_output);
  assign frontend_bufferize_ready = frontend_bufferize_ready_output;
  assign _zz_frontend_split_isForked = frontend_split_valid;
  always @(*) begin
    frontend_split_ready = frontend_split_ready_output;
    if(when_Pipeline_l285) begin
      frontend_split_ready = 1'b0;
    end
  end

  assign when_Pipeline_l285 = (|frontend_split_forkRequest_Axi4Aligner_l320);
  always @(*) begin
    frontend_allocateSlot_ready = 1'b1;
    if(when_Pipeline_l278) begin
      frontend_allocateSlot_ready = 1'b0;
    end
  end

  assign when_Pipeline_l278 = (|{frontend_allocateSlot_haltRequest_Axi4Aligner_l359,frontend_allocateSlot_haltRequest_Axi4Aligner_l342});
  always @(*) begin
    frontend_bufferize_ready_output = frontend_split_ready;
    if(when_Connection_l74) begin
      frontend_bufferize_ready_output = 1'b1;
    end
  end

  assign when_Connection_l74 = (! frontend_split_valid);
  always @(*) begin
    frontend_split_ready_output = frontend_allocateSlot_ready;
    if(when_Connection_l74_1) begin
      frontend_split_ready_output = 1'b1;
    end
  end

  assign when_Connection_l74_1 = (! frontend_allocateSlot_valid);
  assign io_down_r_ready = 1'b1;
  always @(*) begin
    rData_write_valid = 1'b0;
    if(io_down_r_fire) begin
      rData_write_valid = 1'b1;
    end
  end

  assign rData_write_payload_address = {io_down_r_payload_id,downR_counter};
  assign rData_write_payload_data = io_down_r_payload_data;
  assign io_down_r_fire = (io_down_r_valid && io_down_r_ready);
  assign upR_fetch_valid = (ptr_cmd != ptr_fetch);
  always @(*) begin
    context_read_cmd_valid = 1'b0;
    if(upR_fetch_isFireing) begin
      context_read_cmd_valid = 1'b1;
    end
  end

  assign context_read_cmd_payload = ptr_fetch[1:0];
  assign upR_fetch_isFireing = (upR_fetch_valid && upR_fetch_ready);
  assign upR_handle_CTX_last = context_read_rsp_last;
  assign upR_handle_CTX_id = context_read_rsp_id;
  assign upR_handle_CTX_header = context_read_rsp_header;
  assign upR_handle_CTX_ups = context_read_rsp_ups;
  assign _zz_upR_handle_done = ptr_rsp;
  assign upR_handle_done = _zz_upR_handle_done_1;
  assign upR_handle_error = _zz_upR_handle_error;
  assign upR_handle_isFireing = (upR_handle_valid && upR_handle_ready);
  assign when_Axi4Aligner_l411 = (upR_handle_isFireing && upR_handle_error);
  assign upR_handle_CHUNK_LAST = (upR_handle_counter == upR_handle_CTX_ups);
  assign upR_handle_ERRORED = (upR_handle_error || upR_handle_errorAcc);
  assign upR_handle_haltRequest_Axi4Aligner_l416 = (! upR_handle_done);
  always @(*) begin
    rData_read_cmd_valid = 1'b0;
    if(when_Axi4Aligner_l420) begin
      if(upR_handle_isForked) begin
        rData_read_cmd_valid = 1'b1;
      end
    end
  end

  assign rData_read_cmd_payload = {ptr_rsp[1 : 0],_zz_rData_read_cmd_payload};
  assign when_Axi4Aligner_l420 = (upR_handle_valid && upR_handle_done);
  assign when_Axi4Aligner_l421 = (! upR_handle_CHUNK_LAST);
  assign upR_handle_forkRequest_Axi4Aligner_l422 = _zz_upR_handle_forkRequest_Axi4Aligner_l422;
  assign io_up_r_isStall = (io_up_r_valid && (! io_up_r_ready));
  assign upR_rsp_haltRequest_Axi4Aligner_l438 = io_up_r_isStall;
  assign io_up_r_valid = upR_rsp_valid;
  assign io_up_r_payload_last = (upR_rsp_handle_CTX_last && upR_handle_CHUNK_LAST);
  assign io_up_r_payload_id = upR_rsp_handle_CTX_id;
  assign io_up_r_payload_data = rData_read_rsp;
  always @(*) begin
    io_up_r_payload_resp = 2'b00;
    if(upR_rsp_handle_ERRORED) begin
      io_up_r_payload_resp = 2'b10;
    end
  end

  assign upR_handle_isForked = (_zz_upR_handle_isForked && upR_handle_ready_output);
  assign upR_fetch_ready = upR_fetch_ready_output;
  always @(*) begin
    _zz_upR_handle_isForked = upR_handle_valid;
    if(when_Pipeline_l278_1) begin
      _zz_upR_handle_isForked = 1'b0;
    end
  end

  always @(*) begin
    upR_handle_ready = upR_handle_ready_output;
    if(when_Pipeline_l278_1) begin
      upR_handle_ready = 1'b0;
    end
    if(when_Pipeline_l285_1) begin
      upR_handle_ready = 1'b0;
    end
  end

  assign when_Pipeline_l278_1 = (|upR_handle_haltRequest_Axi4Aligner_l416);
  assign when_Pipeline_l285_1 = (|upR_handle_forkRequest_Axi4Aligner_l422);
  always @(*) begin
    upR_rsp_ready = 1'b1;
    if(when_Pipeline_l278_2) begin
      upR_rsp_ready = 1'b0;
    end
  end

  assign when_Pipeline_l278_2 = (|upR_rsp_haltRequest_Axi4Aligner_l438);
  always @(*) begin
    upR_fetch_ready_output = upR_handle_ready;
    if(when_Connection_l74_2) begin
      upR_fetch_ready_output = 1'b1;
    end
  end

  assign when_Connection_l74_2 = (! upR_handle_valid);
  always @(*) begin
    upR_handle_ready_output = upR_rsp_ready;
    if(when_Connection_l74_3) begin
      upR_handle_ready_output = 1'b1;
    end
  end

  assign when_Connection_l74_3 = (! upR_rsp_valid);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ptr_cmd <= 3'b000;
      ptr_fetch <= 3'b000;
      ptr_rsp <= 3'b000;
      frontend_split_spliter_blockCounter <= 7'h0;
      frontend_split_valid <= 1'b0;
      frontend_allocateSlot_valid <= 1'b0;
      downR_counter <= 3'b000;
      upR_handle_errorAcc <= 1'b0;
      upR_handle_counter <= 3'b000;
      upR_handle_valid <= 1'b0;
      upR_rsp_valid <= 1'b0;
    end else begin
      if(frontend_split_isForked) begin
        frontend_split_spliter_blockCounter <= (frontend_split_spliter_blockCounter + 7'h01);
        if(frontend_split_spliter_LAST) begin
          frontend_split_spliter_blockCounter <= 7'h0;
        end
      end
      if(frontend_allocateSlot_isFireing) begin
        ptr_cmd <= (ptr_cmd + 3'b001);
      end
      if(frontend_bufferize_ready_output) begin
        frontend_split_valid <= frontend_bufferize_valid;
      end
      if(frontend_split_ready_output) begin
        frontend_allocateSlot_valid <= _zz_frontend_split_isForked;
      end
      if(io_down_r_fire) begin
        downR_counter <= (downR_counter + 3'b001);
        if(io_down_r_payload_last) begin
          downR_counter <= 3'b000;
        end
      end
      if(upR_fetch_isFireing) begin
        ptr_fetch <= (ptr_fetch + 3'b001);
      end
      if(when_Axi4Aligner_l411) begin
        upR_handle_errorAcc <= 1'b1;
      end
      if(when_Axi4Aligner_l420) begin
        if(upR_handle_isForked) begin
          upR_handle_counter <= (upR_handle_counter + 3'b001);
          if(upR_handle_CHUNK_LAST) begin
            upR_handle_counter <= 3'b000;
            upR_handle_errorAcc <= 1'b0;
            ptr_rsp <= (ptr_rsp + 3'b001);
          end
        end
      end
      if(upR_fetch_ready_output) begin
        upR_handle_valid <= upR_fetch_valid;
      end
      if(upR_handle_ready_output) begin
        upR_rsp_valid <= _zz_upR_handle_isForked;
      end
    end
  end

  always @(posedge clk) begin
    if(frontend_allocateSlot_isFireing) begin
      case(switch_Utils_l1436)
        2'b00 : begin
          slots_0_done <= 1'b0;
          slots_0_error <= 1'b0;
        end
        2'b01 : begin
          slots_1_done <= 1'b0;
          slots_1_error <= 1'b0;
        end
        2'b10 : begin
          slots_2_done <= 1'b0;
          slots_2_error <= 1'b0;
        end
        default : begin
          slots_3_done <= 1'b0;
          slots_3_error <= 1'b0;
        end
      endcase
    end
    if(frontend_bufferize_ready_output) begin
      frontend_split_bufferize_AR_addr <= frontend_bufferize_AR_addr;
      frontend_split_bufferize_AR_id <= frontend_bufferize_AR_id;
      frontend_split_bufferize_AR_region <= frontend_bufferize_AR_region;
      frontend_split_bufferize_AR_len <= frontend_bufferize_AR_len;
      frontend_split_bufferize_AR_size <= frontend_bufferize_AR_size;
      frontend_split_bufferize_AR_burst <= frontend_bufferize_AR_burst;
      frontend_split_bufferize_AR_lock <= frontend_bufferize_AR_lock;
      frontend_split_bufferize_AR_cache <= frontend_bufferize_AR_cache;
      frontend_split_bufferize_AR_qos <= frontend_bufferize_AR_qos;
      frontend_split_bufferize_AR_prot <= frontend_bufferize_AR_prot;
    end
    if(frontend_split_ready_output) begin
      frontend_allocateSlot_bufferize_AR_addr <= frontend_split_bufferize_AR_addr;
      frontend_allocateSlot_bufferize_AR_id <= frontend_split_bufferize_AR_id;
      frontend_allocateSlot_bufferize_AR_region <= frontend_split_bufferize_AR_region;
      frontend_allocateSlot_bufferize_AR_len <= frontend_split_bufferize_AR_len;
      frontend_allocateSlot_bufferize_AR_size <= frontend_split_bufferize_AR_size;
      frontend_allocateSlot_bufferize_AR_burst <= frontend_split_bufferize_AR_burst;
      frontend_allocateSlot_bufferize_AR_lock <= frontend_split_bufferize_AR_lock;
      frontend_allocateSlot_bufferize_AR_cache <= frontend_split_bufferize_AR_cache;
      frontend_allocateSlot_bufferize_AR_qos <= frontend_split_bufferize_AR_qos;
      frontend_allocateSlot_bufferize_AR_prot <= frontend_split_bufferize_AR_prot;
      frontend_allocateSlot_split_spliter_LAST <= frontend_split_spliter_LAST;
      frontend_allocateSlot_split_spliter_FIRST <= frontend_split_spliter_FIRST;
      frontend_allocateSlot_split_spliter_BOUNDED_BLOCK <= frontend_split_spliter_BOUNDED_BLOCK;
      frontend_allocateSlot_split_spliter_CHUNKS_WORDS <= frontend_split_spliter_CHUNKS_WORDS;
      frontend_allocateSlot_split_aligner_CHUNK_START <= frontend_split_aligner_CHUNK_START;
      frontend_allocateSlot_split_aligner_CHUNK_END <= frontend_split_aligner_CHUNK_END;
      frontend_allocateSlot_split_aligner_LEN <= frontend_split_aligner_LEN;
    end
    if(io_down_r_fire) begin
      if(io_down_r_payload_last) begin
        case(io_down_r_payload_id)
          2'b00 : begin
            slots_0_done <= 1'b1;
            slots_0_error <= (! (io_down_r_payload_resp == 2'b00));
          end
          2'b01 : begin
            slots_1_done <= 1'b1;
            slots_1_error <= (! (io_down_r_payload_resp == 2'b00));
          end
          2'b10 : begin
            slots_2_done <= 1'b1;
            slots_2_error <= (! (io_down_r_payload_resp == 2'b00));
          end
          default : begin
            slots_3_done <= 1'b1;
            slots_3_error <= (! (io_down_r_payload_resp == 2'b00));
          end
        endcase
      end
    end
    if(upR_handle_ready_output) begin
      upR_rsp_handle_CTX_last <= upR_handle_CTX_last;
      upR_rsp_handle_CTX_id <= upR_handle_CTX_id;
      upR_rsp_handle_CTX_header <= upR_handle_CTX_header;
      upR_rsp_handle_CTX_ups <= upR_handle_CTX_ups;
      upR_rsp_handle_ERRORED <= upR_handle_ERRORED;
    end
  end


endmodule

module Axi4ReadOnlyCompactor (
  input  wire          io_up_ar_valid,
  output wire          io_up_ar_ready,
  input  wire [31:0]   io_up_ar_payload_addr,
  input  wire [3:0]    io_up_ar_payload_id,
  input  wire [3:0]    io_up_ar_payload_region,
  input  wire [7:0]    io_up_ar_payload_len,
  input  wire [2:0]    io_up_ar_payload_size,
  input  wire [1:0]    io_up_ar_payload_burst,
  input  wire [0:0]    io_up_ar_payload_lock,
  input  wire [3:0]    io_up_ar_payload_cache,
  input  wire [3:0]    io_up_ar_payload_qos,
  input  wire [2:0]    io_up_ar_payload_prot,
  output wire          io_up_r_valid,
  input  wire          io_up_r_ready,
  output wire [31:0]   io_up_r_payload_data,
  output wire [3:0]    io_up_r_payload_id,
  output wire [1:0]    io_up_r_payload_resp,
  output wire          io_up_r_payload_last,
  output wire          io_down_ar_valid,
  input  wire          io_down_ar_ready,
  output wire [31:0]   io_down_ar_payload_addr,
  output wire [3:0]    io_down_ar_payload_id,
  output wire [3:0]    io_down_ar_payload_region,
  output wire [7:0]    io_down_ar_payload_len,
  output wire [2:0]    io_down_ar_payload_size,
  output wire [1:0]    io_down_ar_payload_burst,
  output wire [0:0]    io_down_ar_payload_lock,
  output wire [3:0]    io_down_ar_payload_cache,
  output wire [3:0]    io_down_ar_payload_qos,
  output wire [2:0]    io_down_ar_payload_prot,
  input  wire          io_down_r_valid,
  output wire          io_down_r_ready,
  input  wire [31:0]   io_down_r_payload_data,
  input  wire [3:0]    io_down_r_payload_id,
  input  wire [1:0]    io_down_r_payload_resp,
  input  wire          io_down_r_payload_last,
  input  wire          clk,
  input  wire          reset
);

  reg        [11:0]   context_mem_spinal_port1;
  wire       [11:0]   _zz_context_mem_port;
  wire       [14:0]   _zz_onAr_bytes;
  wire       [14:0]   _zz_onAr_bytes_1;
  wire       [14:0]   _zz_onAr_bytesBeats;
  wire       [1:0]    _zz_onAr_bytesBeats_1;
  wire       [1:0]    _zz_onAr_bytesBeats_2;
  wire       [1:0]    _zz_onAr_bytesBeats_3;
  reg        [1:0]    _zz_onAr_smallSize;
  wire       [1:0]    _zz_onAr_smallSize_1;
  wire       [1:0]    _zz_io_down_ar_payload_size;
  wire       [12:0]   _zz_io_down_ar_payload_len;
  wire       [7:0]    _zz_context_write_payload_data_bytePerBeat;
  wire       [7:0]    _zz_context_write_payload_data_bytePerBeat_1;
  wire       [2:0]    _zz_onR_process_wordCounterPlus;
  wire       [2:0]    _zz_onR_process_wordCounterPlus_1;
  wire       [2:0]    _zz_onR_process_wordCounterPlus_2;
  wire       [1:0]    _zz_onR_process_wordCounterPlus_3;
  reg                 onR_process_ready;
  reg        [31:0]   onR_process_fetch_R_data;
  reg        [3:0]    onR_process_fetch_R_id;
  reg        [1:0]    onR_process_fetch_R_resp;
  reg                 onR_process_fetch_R_last;
  wire       [7:0]    onR_process_CTX_len;
  wire       [1:0]    onR_process_CTX_bytePerBeat;
  wire       [1:0]    onR_process_CTX_offset;
  wire       [31:0]   onR_fetch_R_data;
  wire       [3:0]    onR_fetch_R_id;
  wire       [1:0]    onR_fetch_R_resp;
  wire                onR_fetch_R_last;
  wire                onR_fetch_ready;
  reg                 _zz_1;
  wire                context_write_valid;
  wire       [3:0]    context_write_payload_address;
  wire       [7:0]    context_write_payload_data_len;
  wire       [1:0]    context_write_payload_data_bytePerBeat;
  wire       [1:0]    context_write_payload_data_offset;
  wire                context_read_cmd_valid;
  wire       [3:0]    context_read_cmd_payload;
  wire       [7:0]    context_read_rsp_len;
  wire       [1:0]    context_read_rsp_bytePerBeat;
  wire       [1:0]    context_read_rsp_offset;
  wire       [11:0]   _zz_context_read_rsp_len;
  reg        [1:0]    onAr_sizeBytes;
  wire       [14:0]   onAr_bytes;
  wire       [14:0]   onAr_bytesBeats;
  wire       [1:0]    onAr_smallSize;
  wire                io_down_ar_fire;
  wire                onR_fetch_valid;
  wire                onR_fetch_isFireing;
  reg                 onR_process_valid;
  reg                 onR_process_first;
  wire                io_up_r_fire;
  reg        [7:0]    onR_process_lenCounter;
  wire                onR_process_lenLast;
  reg        [1:0]    onR_process_wordCounter;
  wire       [2:0]    onR_process_wordCounterPlus;
  wire                onR_process_wordLast;
  wire                onR_process_haltRequest_Axi4Compactor_l171;
  wire                onR_process_haltRequest_Axi4Compactor_l172;
  reg                 onR_fetch_ready_output;
  wire                when_Pipeline_l278;
  wire                when_Connection_l74;
  reg [11:0] context_mem [0:15];

  assign _zz_onAr_bytes = ({7'd0,io_up_ar_payload_len} <<< io_up_ar_payload_size);
  assign _zz_onAr_bytes_1 = {13'd0, onAr_sizeBytes};
  assign _zz_onAr_bytesBeats_1 = (io_up_ar_payload_addr[1 : 0] & (~ _zz_onAr_bytesBeats_2));
  assign _zz_onAr_bytesBeats = {13'd0, _zz_onAr_bytesBeats_1};
  assign _zz_onAr_bytesBeats_2 = (_zz_onAr_bytesBeats_3 - 2'b01);
  assign _zz_onAr_bytesBeats_3 = (2'b01 <<< io_up_ar_payload_size);
  assign _zz_io_down_ar_payload_size = ((|io_down_ar_payload_len) ? 2'b10 : onAr_smallSize);
  assign _zz_io_down_ar_payload_len = (onAr_bytesBeats >>> 2'd2);
  assign _zz_context_write_payload_data_bytePerBeat = (_zz_context_write_payload_data_bytePerBeat_1 - 8'h01);
  assign _zz_context_write_payload_data_bytePerBeat_1 = ({7'd0,1'b1} <<< io_up_ar_payload_size);
  assign _zz_onR_process_wordCounterPlus = (_zz_onR_process_wordCounterPlus_1 + _zz_onR_process_wordCounterPlus_2);
  assign _zz_onR_process_wordCounterPlus_1 = ({1'b0,onR_process_wordCounter} + {1'b0,onR_process_CTX_bytePerBeat});
  assign _zz_onR_process_wordCounterPlus_3 = (onR_process_first ? onR_process_CTX_offset : 2'b00);
  assign _zz_onR_process_wordCounterPlus_2 = {1'd0, _zz_onR_process_wordCounterPlus_3};
  assign _zz_context_mem_port = {context_write_payload_data_offset,{context_write_payload_data_bytePerBeat,context_write_payload_data_len}};
  assign _zz_onAr_smallSize_1 = onAr_bytesBeats[1 : 0];
  always @(posedge clk) begin
    if(_zz_1) begin
      context_mem[context_write_payload_address] <= _zz_context_mem_port;
    end
  end

  always @(posedge clk) begin
    if(context_read_cmd_valid) begin
      context_mem_spinal_port1 <= context_mem[context_read_cmd_payload];
    end
  end

  always @(*) begin
    case(_zz_onAr_smallSize_1)
      2'b00 : _zz_onAr_smallSize = 2'b00;
      2'b01 : _zz_onAr_smallSize = 2'b01;
      2'b10 : _zz_onAr_smallSize = 2'b10;
      default : _zz_onAr_smallSize = 2'b10;
    endcase
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(context_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign _zz_context_read_rsp_len = context_mem_spinal_port1;
  assign context_read_rsp_len = _zz_context_read_rsp_len[7 : 0];
  assign context_read_rsp_bytePerBeat = _zz_context_read_rsp_len[9 : 8];
  assign context_read_rsp_offset = _zz_context_read_rsp_len[11 : 10];
  assign io_down_ar_valid = io_up_ar_valid;
  assign io_up_ar_ready = io_down_ar_ready;
  assign io_down_ar_payload_addr = io_up_ar_payload_addr;
  assign io_down_ar_payload_id = io_up_ar_payload_id;
  assign io_down_ar_payload_region = io_up_ar_payload_region;
  assign io_down_ar_payload_burst = io_up_ar_payload_burst;
  assign io_down_ar_payload_lock = io_up_ar_payload_lock;
  assign io_down_ar_payload_cache = io_up_ar_payload_cache;
  assign io_down_ar_payload_qos = io_up_ar_payload_qos;
  assign io_down_ar_payload_prot = io_up_ar_payload_prot;
  always @(*) begin
    onAr_sizeBytes = 2'bxx;
    case(io_up_ar_payload_size)
      3'b000 : begin
        onAr_sizeBytes = 2'b00;
      end
      3'b001 : begin
        onAr_sizeBytes = 2'b01;
      end
      3'b010 : begin
        onAr_sizeBytes = 2'b11;
      end
      default : begin
      end
    endcase
  end

  assign onAr_bytes = (_zz_onAr_bytes + _zz_onAr_bytes_1);
  assign onAr_bytesBeats = (onAr_bytes + _zz_onAr_bytesBeats);
  assign onAr_smallSize = _zz_onAr_smallSize;
  assign io_down_ar_payload_size = {1'd0, _zz_io_down_ar_payload_size};
  assign io_down_ar_payload_len = _zz_io_down_ar_payload_len[7:0];
  assign io_down_ar_fire = (io_down_ar_valid && io_down_ar_ready);
  assign context_write_valid = io_down_ar_fire;
  assign context_write_payload_address = io_up_ar_payload_id;
  assign context_write_payload_data_len = io_up_ar_payload_len;
  assign context_write_payload_data_bytePerBeat = _zz_context_write_payload_data_bytePerBeat[1:0];
  assign context_write_payload_data_offset = (io_up_ar_payload_addr[1 : 0] & (~ context_write_payload_data_bytePerBeat));
  assign onR_fetch_valid = io_down_r_valid;
  assign io_down_r_ready = onR_fetch_ready;
  assign onR_fetch_R_data = io_down_r_payload_data;
  assign onR_fetch_R_id = io_down_r_payload_id;
  assign onR_fetch_R_resp = io_down_r_payload_resp;
  assign onR_fetch_R_last = io_down_r_payload_last;
  assign onR_fetch_isFireing = (onR_fetch_valid && onR_fetch_ready);
  assign context_read_cmd_valid = onR_fetch_isFireing;
  assign context_read_cmd_payload = io_down_r_payload_id;
  assign onR_process_CTX_len = context_read_rsp_len;
  assign onR_process_CTX_bytePerBeat = context_read_rsp_bytePerBeat;
  assign onR_process_CTX_offset = context_read_rsp_offset;
  assign io_up_r_fire = (io_up_r_valid && io_up_r_ready);
  assign onR_process_lenLast = (onR_process_lenCounter == onR_process_CTX_len);
  assign onR_process_wordCounterPlus = (_zz_onR_process_wordCounterPlus + 3'b001);
  assign onR_process_wordLast = (onR_process_wordCounterPlus[2] || onR_process_lenLast);
  assign onR_process_haltRequest_Axi4Compactor_l171 = (! onR_process_wordLast);
  assign onR_process_haltRequest_Axi4Compactor_l172 = (! io_up_r_ready);
  assign io_up_r_valid = onR_process_valid;
  assign io_up_r_payload_data = onR_process_fetch_R_data;
  assign io_up_r_payload_id = onR_process_fetch_R_id;
  assign io_up_r_payload_resp = onR_process_fetch_R_resp;
  assign io_up_r_payload_last = onR_process_lenLast;
  assign onR_fetch_ready = onR_fetch_ready_output;
  always @(*) begin
    onR_process_ready = 1'b1;
    if(when_Pipeline_l278) begin
      onR_process_ready = 1'b0;
    end
  end

  assign when_Pipeline_l278 = (|{onR_process_haltRequest_Axi4Compactor_l172,onR_process_haltRequest_Axi4Compactor_l171});
  always @(*) begin
    onR_fetch_ready_output = onR_process_ready;
    if(when_Connection_l74) begin
      onR_fetch_ready_output = 1'b1;
    end
  end

  assign when_Connection_l74 = (! onR_process_valid);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      onR_process_first <= 1'b1;
      onR_process_lenCounter <= 8'h0;
      onR_process_wordCounter <= 2'b00;
      onR_process_valid <= 1'b0;
    end else begin
      if(io_up_r_fire) begin
        onR_process_first <= io_up_r_payload_last;
      end
      if(io_up_r_fire) begin
        onR_process_wordCounter <= onR_process_wordCounterPlus[1:0];
        onR_process_lenCounter <= (onR_process_lenCounter + 8'h01);
        if(io_up_r_payload_last) begin
          onR_process_lenCounter <= 8'h0;
          onR_process_wordCounter <= 2'b00;
        end
      end
      if(onR_fetch_ready_output) begin
        onR_process_valid <= onR_fetch_valid;
      end
    end
  end

  always @(posedge clk) begin
    if(onR_fetch_ready_output) begin
      onR_process_fetch_R_data <= onR_fetch_R_data;
      onR_process_fetch_R_id <= onR_fetch_R_id;
      onR_process_fetch_R_resp <= onR_fetch_R_resp;
      onR_process_fetch_R_last <= onR_fetch_R_last;
    end
  end


endmodule

module Axi4ReadOnlyOnePerId (
  input  wire          io_up_ar_valid,
  output wire          io_up_ar_ready,
  input  wire [31:0]   io_up_ar_payload_addr,
  input  wire [3:0]    io_up_ar_payload_id,
  input  wire [3:0]    io_up_ar_payload_region,
  input  wire [7:0]    io_up_ar_payload_len,
  input  wire [2:0]    io_up_ar_payload_size,
  input  wire [1:0]    io_up_ar_payload_burst,
  input  wire [0:0]    io_up_ar_payload_lock,
  input  wire [3:0]    io_up_ar_payload_cache,
  input  wire [3:0]    io_up_ar_payload_qos,
  input  wire [2:0]    io_up_ar_payload_prot,
  output wire          io_up_r_valid,
  input  wire          io_up_r_ready,
  output wire [31:0]   io_up_r_payload_data,
  output wire [3:0]    io_up_r_payload_id,
  output wire [1:0]    io_up_r_payload_resp,
  output wire          io_up_r_payload_last,
  output wire          io_down_ar_valid,
  input  wire          io_down_ar_ready,
  output wire [31:0]   io_down_ar_payload_addr,
  output wire [3:0]    io_down_ar_payload_id,
  output wire [3:0]    io_down_ar_payload_region,
  output wire [7:0]    io_down_ar_payload_len,
  output wire [2:0]    io_down_ar_payload_size,
  output wire [1:0]    io_down_ar_payload_burst,
  output wire [0:0]    io_down_ar_payload_lock,
  output wire [3:0]    io_down_ar_payload_cache,
  output wire [3:0]    io_down_ar_payload_qos,
  output wire [2:0]    io_down_ar_payload_prot,
  input  wire          io_down_r_valid,
  output wire          io_down_r_ready,
  input  wire [31:0]   io_down_r_payload_data,
  input  wire [3:0]    io_down_r_payload_id,
  input  wire [1:0]    io_down_r_payload_resp,
  input  wire          io_down_r_payload_last,
  input  wire          clk,
  input  wire          reset
);

  reg        [15:0]   pendings_valids;
  wire                onAw_busy;
  wire                _zz_io_up_ar_ready;
  wire                onAw_halted_valid;
  wire                onAw_halted_ready;
  wire       [31:0]   onAw_halted_payload_addr;
  wire       [3:0]    onAw_halted_payload_id;
  wire       [3:0]    onAw_halted_payload_region;
  wire       [7:0]    onAw_halted_payload_len;
  wire       [2:0]    onAw_halted_payload_size;
  wire       [1:0]    onAw_halted_payload_burst;
  wire       [0:0]    onAw_halted_payload_lock;
  wire       [3:0]    onAw_halted_payload_cache;
  wire       [3:0]    onAw_halted_payload_qos;
  wire       [2:0]    onAw_halted_payload_prot;
  wire                onAw_halted_fire;
  wire                io_down_r_fire;
  wire                when_Axi4OnePerId_l78;

  assign onAw_busy = pendings_valids[io_up_ar_payload_id];
  assign _zz_io_up_ar_ready = (! onAw_busy);
  assign onAw_halted_valid = (io_up_ar_valid && _zz_io_up_ar_ready);
  assign io_up_ar_ready = (onAw_halted_ready && _zz_io_up_ar_ready);
  assign onAw_halted_payload_addr = io_up_ar_payload_addr;
  assign onAw_halted_payload_id = io_up_ar_payload_id;
  assign onAw_halted_payload_region = io_up_ar_payload_region;
  assign onAw_halted_payload_len = io_up_ar_payload_len;
  assign onAw_halted_payload_size = io_up_ar_payload_size;
  assign onAw_halted_payload_burst = io_up_ar_payload_burst;
  assign onAw_halted_payload_lock = io_up_ar_payload_lock;
  assign onAw_halted_payload_cache = io_up_ar_payload_cache;
  assign onAw_halted_payload_qos = io_up_ar_payload_qos;
  assign onAw_halted_payload_prot = io_up_ar_payload_prot;
  assign onAw_halted_fire = (onAw_halted_valid && onAw_halted_ready);
  assign io_down_ar_valid = onAw_halted_valid;
  assign onAw_halted_ready = io_down_ar_ready;
  assign io_down_ar_payload_addr = onAw_halted_payload_addr;
  assign io_down_ar_payload_id = onAw_halted_payload_id;
  assign io_down_ar_payload_region = onAw_halted_payload_region;
  assign io_down_ar_payload_len = onAw_halted_payload_len;
  assign io_down_ar_payload_size = onAw_halted_payload_size;
  assign io_down_ar_payload_burst = onAw_halted_payload_burst;
  assign io_down_ar_payload_lock = onAw_halted_payload_lock;
  assign io_down_ar_payload_cache = onAw_halted_payload_cache;
  assign io_down_ar_payload_qos = onAw_halted_payload_qos;
  assign io_down_ar_payload_prot = onAw_halted_payload_prot;
  assign io_up_r_valid = io_down_r_valid;
  assign io_down_r_ready = io_up_r_ready;
  assign io_up_r_payload_data = io_down_r_payload_data;
  assign io_up_r_payload_id = io_down_r_payload_id;
  assign io_up_r_payload_resp = io_down_r_payload_resp;
  assign io_up_r_payload_last = io_down_r_payload_last;
  assign io_down_r_fire = (io_down_r_valid && io_down_r_ready);
  assign when_Axi4OnePerId_l78 = (io_down_r_fire && io_down_r_payload_last);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      pendings_valids <= 16'h0;
    end else begin
      if(onAw_halted_fire) begin
        pendings_valids[io_up_ar_payload_id] <= 1'b1;
      end
      if(when_Axi4OnePerId_l78) begin
        pendings_valids[io_down_r_payload_id] <= 1'b0;
      end
    end
  end


endmodule

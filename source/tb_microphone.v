/*
 * @Description:！这个防止文件的激励信号有bug,导致仿真第1个ws周期的信号错误 后面的信号就好了
 * @Author: Tomood
 * @Date: 2024-05-13 23:51:42
 * @LastEditors: Tomood
 * @LastEditTime: 2024-05-14 04:42:10
 * @FilePath: \undefinede:\FPGA\PangoProjects\MicArray\source\tb_microphone.v
 * Copyright (c) 2024 by Tomood, All Rights Reserved. 
 */
`timescale 1ns / 1ps

module tb_MEMs_microphone_driver;

  //时钟周期 100ns 10Mhz
  parameter PERIOD = 100;


  // MEMs_microphone_driver Inputs
  reg           clk = 1;
  reg           rst_n = 0;
  wire          mic_ch0_sdin;
  wire          mic_ch1_sdin;
  wire          mic_ch2_sdin;

  // MEMs_microphone_driver Outputs
  wire          mic_sck;
  wire          mic_ws;
  wire [24-1:0] mic0_data_o;
  wire [24-1:0] mic1_data_o;
  wire [24-1:0] mic2_data_o;
  wire [24-1:0] mic3_data_o;
  wire [24-1:0] mic4_data_o;
  wire [24-1:0] mic5_data_o;
  wire          mic_data_vld_o;

  //###############################
  //GTP_GRS
  //###############################
  reg           grs_n;
  GTP_GRS GRS_INST (.GRS_N(grs_n));
  initial begin
    grs_n = 1'b0;
    #5000 grs_n = 1'b1;
  end

  initial begin
    forever #(PERIOD / 2) clk = ~clk;
  end

  initial begin
    #(PERIOD * 2) rst_n = 1;
  end

  //********************************************************************//
  //***************  激励信号 i2s_slave Transmit 模拟   *****************//
  //********************************************************************//
  reg  [     1:0] ws_reg;  //声道选择信号边沿检测寄存器
  wire            ws_edge;  //帧同步信号有效(跳变沿)
  reg  [24 - 1:0] output_sr;  //音频数据寄存器
  reg  [     5:0] cnt;
  //sda
  assign mic_ch0_sdin = output_sr[23];
  assign mic_ch1_sdin = output_sr[23];
  assign mic_ch2_sdin = output_sr[23];


  //cnt:用于计数
  always @(negedge mic_sck or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= 0;
    end else if (!ws_reg[1] & ws_reg[0]) begin
      cnt <= 0;
    end else begin
      cnt <= cnt + 1'b1;
    end
  end


  //ws_reg：打拍寄存器 用于边沿检测
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      //ws默认就是高的
      ws_reg <= 2'b11;
    end else begin
      ws_reg <= {ws_reg[0], mic_ws};  //丢弃ws_reg高位的数据 将mic_ws数据写入到低位
    end
  end

  //ws_edge:ws跳变沿信号
  assign ws_edge = ^ws_reg;

  //output_sr:音频数据寄存器 (下降沿写入)
  always @(negedge mic_sck or negedge rst_n) begin
    if (!rst_n) begin
      output_sr <= 0;
    end else if (ws_edge) begin  //如果ws信号有跳变沿产生
      output_sr <= 24'b110101010101010101010111;  //及时把锁存的数据发出去
    end else begin
      output_sr <= {output_sr[24-2:0], 1'b0};  //移位写入
    end
  end

  MEMs_microphone_driver u_MEMs_microphone_driver (
      //sys
      .clk           (clk),
      .rst_n         (rst_n),
      //数据输入
      .mic_ch0_sdin  (mic_ch0_sdin),
      .mic_ch1_sdin  (mic_ch1_sdin),
      .mic_ch2_sdin  (mic_ch2_sdin),
      //供给mic的时钟 10Mhz
      .mic_sck       (mic_sck),
      //声道选择信号
      .mic_ws        (mic_ws),
      //解析输出的数据
      .mic0_data_o   (mic0_data_o),
      .mic1_data_o   (mic1_data_o),
      .mic2_data_o   (mic2_data_o),
      .mic3_data_o   (mic3_data_o),
      .mic4_data_o   (mic4_data_o),
      .mic5_data_o   (mic5_data_o),
      .mic_data_vld_o(mic_data_vld_o)
  );


endmodule

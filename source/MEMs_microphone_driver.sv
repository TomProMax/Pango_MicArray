/*
 * @Description: i2s麦克风驱动 FPGA as i2s master
 * @Author: Tomood
 * @Date: 2024-05-13 22:07:58
 * @LastEditors: Tomood
 * @LastEditTime: 2024-05-14 04:33:26
 * @FilePath: \undefinede:\FPGA\PangoProjects\MicArray\source\MEMs_microphone_driver.sv
 * Copyright (c) 2024 by Tomood, All Rights Reserved. 
 */
module MEMs_microphone_driver (
    //sys
    input  logic          clk,             //模块逻辑工作时钟
    input  logic          rst_n,           //复位
    //mic0 i2s interface
    output logic          mic_sck,         //mic时钟输入(由FPGA向i2s-Slave提供)
    output logic          mic_ws,          //声道选择信号
    input  logic          mic_ch0_sdin,    //麦克风通道0-i2s数据输入
    input  logic          mic_ch1_sdin,    //麦克风通道1-i2s数据输入
    input  logic          mic_ch2_sdin,    //麦克风通道2-i2s数据输入
    //data interface to user
    output logic          mic_data_vld_o,  //麦克风输出信号使能
    output logic [24-1:0] mic0_data_o,     //麦克风0信号解析输出
    output logic [24-1:0] mic1_data_o,     //麦克风1信号解析输出
    output logic [24-1:0] mic2_data_o,     //麦克风2信号解析输出
    output logic [24-1:0] mic3_data_o,     //麦克风3信号解析输出
    output logic [24-1:0] mic4_data_o,     //麦克风4信号解析输出
    output logic [24-1:0] mic5_data_o      //麦克风5信号解析输出

);
  //********************************************************************//
  //****************** Parameter and Internal Signal *******************//
  //********************************************************************//
  //bit_cnt:用于计数 64max
  logic [5:0] bit_cnt;
  //sr:暂存接收的的音数据
  logic [24-1:0] sr[2:0];
  //********************************************************************//
  //***************************   Main Code   **************************//
  //********************************************************************//
  //GTP_CLKBUFGCE：时钟使能原语
  GTP_CLKBUFGCE #(
      .DEFAULT_VALUE(1'b1)
  ) I_GTP_CLKBUFGCE (
      .CLKIN(clk),
      .CE(rst_n),
      .CLKOUT(mic_sck)
  );

  //bit_cnt:用于计数
  always_ff @(negedge mic_sck or negedge rst_n) begin
    if (!rst_n) begin
      bit_cnt <= 0;
    end else if (bit_cnt == 63) begin
      bit_cnt <= 0;
    end else begin
      bit_cnt <= bit_cnt + 1'b1;
    end
  end

  //mic_ws:声道选择信号(每32周期刷新一次 对齐时钟下降沿)
  always_ff @(negedge mic_sck or negedge rst_n) begin
    if (!rst_n) begin
      mic_ws <= 1'b1;
    end else if (bit_cnt == 0) begin
      mic_ws <= 1'b0;
    end else if ((bit_cnt == 31) | (bit_cnt == 63)) begin
      mic_ws <= ~mic_ws;
    end else begin
      mic_ws <= mic_ws;
    end
  end

  //sr:音频数据寄存器(上升沿读入数据)
  always_ff @(posedge mic_sck or negedge rst_n) begin
    if (!rst_n) begin
      sr[0] <= 24'b0;  //ch0
      sr[1] <= 24'b0;  //ch1
      sr[2] <= 24'b0;  //ch2
    end else if ((bit_cnt == 27) | (bit_cnt == 59)) begin
      //单麦克风数据帧结束 清空sr
      sr[0] <= 24'b0;
      sr[1] <= 24'b0;
      sr[2] <= 24'b0;
    end else if ((bit_cnt >= 1) & (bit_cnt <= 24)) begin
      //左声道数据移位写入
      sr[0] <= {sr[0][24-2:0], mic_ch0_sdin};
      sr[1] <= {sr[1][24-2:0], mic_ch1_sdin};
      sr[2] <= {sr[2][24-2:0], mic_ch2_sdin};
    end else if ((bit_cnt >= 33) & (bit_cnt <= 56)) begin
      //右声道数据移位写入
      sr[0] <= {sr[0][24-2:0], mic_ch0_sdin};
      sr[1] <= {sr[1][24-2:0], mic_ch1_sdin};
      sr[2] <= {sr[2][24-2:0], mic_ch2_sdin};
    end else begin
      sr[0] <= sr[0];
      sr[1] <= sr[1];
      sr[2] <= sr[2];
    end
  end

  //micx_data_o:麦克风信号解析输出
  always_ff @(posedge mic_sck or negedge rst_n) begin
    if (!rst_n) begin
      mic0_data_o <= 0;
      mic1_data_o <= 0;
      mic2_data_o <= 0;
      mic3_data_o <= 0;
      mic4_data_o <= 0;
      mic5_data_o <= 0;
    end else if (bit_cnt == 26) begin
      //接收完左声道数据 输出
      mic0_data_o <= sr[0];  //ch0
      mic2_data_o <= sr[1];  //ch1
      mic4_data_o <= sr[2];  //ch2
    end else if (bit_cnt == 58) begin
      //接收完右声道数据 输出
      mic1_data_o <= sr[0];  //ch0
      mic3_data_o <= sr[1];  //ch1
      mic5_data_o <= sr[2];  //ch2
    end  //锁存
    else begin
      mic0_data_o <= mic0_data_o;
      mic1_data_o <= mic1_data_o;
      mic2_data_o <= mic2_data_o;
      mic3_data_o <= mic3_data_o;
      mic4_data_o <= mic4_data_o;
      mic5_data_o <= mic5_data_o;
    end
  end

  //mic_data_vld_o:麦克风输出信号使能(有效)
  always_ff @(posedge mic_sck or negedge rst_n) begin
    if (!rst_n) begin
      mic_data_vld_o <= 1'b0;
    end else if (bit_cnt == 60) begin
      //bit_cnt == 57时所有数据接收完毕,58赋值，59接收缓存清零，60再使能输出有效
      //反正周期足够 尽量防止skew
      mic_data_vld_o <= 1'b1;
    end else begin
      mic_data_vld_o <= 1'b0;
    end
  end
endmodule

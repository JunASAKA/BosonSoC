/*--------通用异步收发传输器用源文件--------*/

/********** 通用头文件 **********/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/********** 单个头文件 **********/
`include "uart.h"

module uart (
	/********** 时钟 & 复位 **********/
	input  wire				   clk,		 // 时钟
	input  wire				   reset,	 // 异步复位
	/********** 总线接口 **********/
	input  wire				   cs_,		 
	input  wire				   as_,		 
	input  wire				   rw,		 
	input  wire [`UartAddrBus] addr,	 
	input  wire [`WordDataBus] wr_data,	 
	output wire [`WordDataBus] rd_data,	 
	output wire				   rdy_,	 
	/********** 中断 **********/
	output wire				   irq_rx,	 // 接收中断请求信号
	output wire				   irq_tx,	 // 发送中断请求信号
	/********** UART接收发送信号	**********/
	input  wire				   rx,		 // UART接收信号
	output wire				   tx		 // UART发送信号
);

	/********** 控制信号 **********/
	// 接收控制
	wire					   rx_busy;	 // 接收中标志信号
	wire					   rx_end;	 // 接收完成信号
	wire [`ByteDataBus]		   rx_data;	 // 接收的数据
	// 发送控制
	wire					   tx_busy;	 // 发送中标志信号
	wire					   tx_end;	 // 发送完成信号
	wire					   tx_start; // 发送开始信号
	wire [`ByteDataBus]		   tx_data;	 // 发送数据

	/********** UART控制模块 **********/
	uart_ctrl uart_ctrl (
		/********** 时钟 & 复位 **********/
		.clk	  (clk),	   // 时钟
		.reset	  (reset),	   // 异步复位
		/********** Host Interface **********/
		.cs_	  (cs_),	   
		.as_	  (as_),	   
		.rw		  (rw),		   
		.addr	  (addr),	   
		.wr_data  (wr_data),   
		.rd_data  (rd_data),   
		.rdy_	  (rdy_),	   
		/********** Interrupt  **********/
		.irq_rx	  (irq_rx),	   // 接收中断请求信号
		.irq_tx	  (irq_tx),	   // 发送中断请求信号
		/********** 控制信号 **********/
		// 接收控制
		.rx_busy  (rx_busy),   // 接收中标志信号
		.rx_end	  (rx_end),	   // 接收完成信号
		.rx_data  (rx_data),   // 接收的数据
		// 发送控制
		.tx_busy  (tx_busy),   // 发送中标志信号
		.tx_end	  (tx_end),	   // 发送完成信号
		.tx_start (tx_start),  // 发送开始信号
		.tx_data  (tx_data)	   // 发送数据
	);

	/********** UART发送模块 **********/
	uart_tx uart_tx (
		/********** 时钟 & 复位 **********/
		.clk	  (clk),	   // 时钟
		.reset	  (reset),	   // 异步复位
		/********** 控制信号 **********/
		.tx_start (tx_start),  // 发送开始信号
		.tx_data  (tx_data),   // 发送数据
		.tx_busy  (tx_busy),   // 发送中标志信号
		.tx_end	  (tx_end),	   // 发送完成信号
		/********** Transmit Signal **********/
		.tx		  (tx)		   // UART送信信号
	);

	/********** UART接收模块 **********/
	uart_rx uart_rx (
		/********** 时钟 & 复位 **********/
		.clk	  (clk),	   // 时钟
		.reset	  (reset),	   // 异步复位
		/********** 控制信号 **********/
		.rx_busy  (rx_busy),   // 接收中标志信号
		.rx_end	  (rx_end),	   // 接收完成信号
		.rx_data  (rx_data),   // 接收的数据
		/********** Receive Signal **********/
		.rx		  (rx)		   // UART受信信号
	);

endmodule

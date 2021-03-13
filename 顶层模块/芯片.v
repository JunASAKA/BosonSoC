/*--------芯片用源文件--------*/

/********** 通用头文件 **********/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/********** 单个头文件 **********/
`include "cpu.h"
`include "bus.h"
`include "rom.h"
`include "timer.h"
`include "uart.h"
`include "gpio.h"

/********** 模块 **********/
module chip (
	/********** 时钟 & 复位 **********/
	input  wire						 clk,		  // 时钟
	input  wire						 clk_,		  // 反相时钟
	input  wire						 reset		  // 复位
	/********** 通用异步收发传输器  **********/
`ifdef IMPLEMENT_UART // 通用异步收发传输器实现
	, input	 wire					 uart_rx	  // 通用异步收发传输器接收信号
	, output wire					 uart_tx	  // 通用异步收发传输器发发送号
`endif
	/********** 通用输入/输出端口 **********/
`ifdef IMPLEMENT_GPIO // 通用输入输出端口实现
`ifdef GPIO_IN_CH	 // 输入端口的实现
	, input wire [`GPIO_IN_CH-1:0]	 gpio_in	  // 输入端口
`endif
`ifdef GPIO_OUT_CH	 // 输出端口实现
	, output wire [`GPIO_OUT_CH-1:0] gpio_out	  // 输出端口
`endif
`ifdef GPIO_IO_CH	 // 输入/输出端口的实现
	, inout wire [`GPIO_IO_CH-1:0]	 gpio_io	  // 输入输出端口
`endif
`endif
);

	/********** 总线主控信号 **********/
	// 总线主控共享信号~
	wire [`WordDataBus] m_rd_data;				  // 读取数据
	wire				m_rdy_;					  // 就绪
	// 总线主控0
	wire				m0_req_;				  // 总线请求
	wire [`WordAddrBus] m0_addr;				  // 地址
	wire				m0_as_;					  // 地址选通
	wire				m0_rw;					  // 读/写
	wire [`WordDataBus] m0_wr_data;				  // 写入数据
	wire				m0_grnt_;				  // 总线允许
	// 总线主控1
	wire				m1_req_;				  // 总线请求
	wire [`WordAddrBus] m1_addr;				  // 地址
	wire				m1_as_;					  // 地址选通
	wire				m1_rw;					  // 读/写
	wire [`WordDataBus] m1_wr_data;				  // 写入数据
	wire				m1_grnt_;				  // 总线允许
	// 总线主控2
	wire				m2_req_;				  // 总线请求
	wire [`WordAddrBus] m2_addr;				  // 地址
	wire				m2_as_;					  // 地址选通
	wire				m2_rw;					  // 读/写
	wire [`WordDataBus] m2_wr_data;				  // 写入数据
	wire				m2_grnt_;				  // 总线允许
	// 总线主控3
	wire				m3_req_;				  // 总线请求
	wire [`WordAddrBus] m3_addr;				  // 地址
	wire				m3_as_;					  // 地址选通
	wire				m3_rw;					  // 读/写
	wire [`WordDataBus] m3_wr_data;				  // 写入数据
	wire				m3_grnt_;				  // 总线允许
	/********** 总线从属信号 **********/
	// 总线从属共享信号
	wire [`WordAddrBus] s_addr;					  // 地址
	wire				s_as_;					  // 地址选通
	wire				s_rw;					  // 读/写
	wire [`WordDataBus] s_wr_data;				  // 写入数据
	// 总线从属0
	wire [`WordDataBus] s0_rd_data;				  // 读取数据
	wire				s0_rdy_;				  // 就绪
	wire				s0_cs_;					  // 片选
	// 总线从属1
	wire [`WordDataBus] s1_rd_data;				  // 读取数据
	wire				s1_rdy_;				  // 就绪
	wire				s1_cs_;					  // 片选
	// 总线从属2
	wire [`WordDataBus] s2_rd_data;				  // 读取数据
	wire				s2_rdy_;				  // 就绪
	wire				s2_cs_;					  // 片选
	// 总线从属3
	wire [`WordDataBus] s3_rd_data;				  // 读取数据
	wire				s3_rdy_;				  // 就绪
	wire				s3_cs_;					  // 片选
	// 总线从属4
	wire [`WordDataBus] s4_rd_data;				  // 读取数据
	wire				s4_rdy_;				  // 就绪
	wire				s4_cs_;					  // 片选
	// 总线从属5
	wire [`WordDataBus] s5_rd_data;				  // 读取数据
	wire				s5_rdy_;				  // 就绪
	wire				s5_cs_;					  // 片选
	// 总线从属6
	wire [`WordDataBus] s6_rd_data;				  // 读取数据
	wire				s6_rdy_;				  // 就绪
	wire				s6_cs_;					  // 片选
	// 总线从属7
	wire [`WordDataBus] s7_rd_data;				  // 读取数据
	wire				s7_rdy_;				  // 就绪
	wire				s7_cs_;					  // 片选
	/********** 中断要求信号 **********/
	wire				   irq_timer;			  // 计时器中断要求信号
	wire				   irq_uart_rx;			  // 通用异步收发传输器中断要求信号（接收）
	wire				   irq_uart_tx;			  // 通用异步收发传输器中断要求信号（发送）
	wire [`CPU_IRQ_CH-1:0] cpu_irq;				  // 中央处理器中断要求信号

	assign cpu_irq = {{`CPU_IRQ_CH-3{`LOW}}, 
					  irq_uart_rx, irq_uart_tx, irq_timer};

	/********** 中央处理器 **********/
	cpu cpu (
		/********** 时钟 & 复位 **********/
		.clk			 (clk),					  // 时钟
		.clk_			 (clk_),				  // 反相时钟
		.reset			 (reset),				  // 异步复位
		/********** 总线接口 **********/
		// IF Stage
		.if_bus_rd_data	 (m_rd_data),			  // 读取数据
		.if_bus_rdy_	 (m_rdy_),				  // 就绪
		.if_bus_grnt_	 (m0_grnt_),			  // 总线允许
		.if_bus_req_	 (m0_req_),				  // 总线请求
		.if_bus_addr	 (m0_addr),				  // 地址
		.if_bus_as_		 (m0_as_),				  // 地址选通
		.if_bus_rw		 (m0_rw),				  // 读/写
		.if_bus_wr_data	 (m0_wr_data),			  // 写入数据
		// MEM Stage
		.mem_bus_rd_data (m_rd_data),			  // 读取数据
		.mem_bus_rdy_	 (m_rdy_),				  // 就绪
		.mem_bus_grnt_	 (m1_grnt_),			  // 总线允许
		.mem_bus_req_	 (m1_req_),				  // 总线请求
		.mem_bus_addr	 (m1_addr),				  // 地址
		.mem_bus_as_	 (m1_as_),				  // 地址选通
		.mem_bus_rw		 (m1_rw),				  // 读/写
		.mem_bus_wr_data (m1_wr_data),			  // 写入数据
		/********** 中断 **********/
		.cpu_irq		 (cpu_irq)				  // 中断要求
	);

	/********** 总线主控 2 : 未分配 **********/
	assign m2_addr	  = `WORD_ADDR_W'h0;
	assign m2_as_	  = `DISABLE_;
	assign m2_rw	  = `READ;
	assign m2_wr_data = `WORD_DATA_W'h0;
	assign m2_req_	  = `DISABLE_;

	/********** 总线主控 3 : 未分配 **********/
	assign m3_addr	  = `WORD_ADDR_W'h0;
	assign m3_as_	  = `DISABLE_;
	assign m3_rw	  = `READ;
	assign m3_wr_data = `WORD_DATA_W'h0;
	assign m3_req_	  = `DISABLE_;
   
	/********** 总线从属 0 : 只读储存器 **********/
	rom rom (
		/********** 时钟 & 复位 **********/
		.clk			 (clk),					  // 时钟
		.reset			 (reset),				  // 异步复位
		/********** 总线信号 **********/
		.cs_			 (s0_cs_),				  // 片选
		.as_			 (s_as_),				  // 地址选通
		.addr			 (s_addr[`RomAddrPosit]),	  // 地址
		.rd_data		 (s0_rd_data),			  // 读取数据
		.rdy_			 (s0_rdy_)				  // 就绪
	);

	/********** 总线从属 1 : 便笺式储存器 **********/
	assign s1_rd_data = `WORD_DATA_W'h0;
	assign s1_rdy_	  = `DISABLE_;

	/********** 总线从属 2 : 计时器 **********/
`ifdef IMPLEMENT_TIMER // 分配至计时器
	timer timer (
		/********** 时钟 & 复位 **********/
		.clk			 (clk),					  // 时钟
		.reset			 (reset),				  // 复位
		/********** 总线信号 **********/
		.cs_			 (s2_cs_),				  // 片选
		.as_			 (s_as_),				  // 地址选通
		.addr			 (s_addr[`TimerAddrPosit]), // 地址
		.rw				 (s_rw),				  // 读/写
		.wr_data		 (s_wr_data),			  // 写入数据
		.rd_data		 (s2_rd_data),			  // 读取数据
		.rdy_			 (s2_rdy_),				  // 就绪
		/********** 中断 **********/
		.irq			 (irq_timer)			  // 中断要求
	 );
`else				   // 计时器为被分配
	assign s2_rd_data = `WORD_DATA_W'h0;
	assign s2_rdy_	  = `DISABLE_;
	assign irq_timer  = `DISABLE;
`endif

	/********** 总线从属 3 : 通用异步收发传输器 **********/
`ifdef IMPLEMENT_UART // 分配至通用异步收发传输器
	uart uart (
		/********** 时钟 & 复位 **********/
		.clk			 (clk),					  // 时钟
		.reset			 (reset),				  // 异步复位
		/********** 总线信号 **********/
		.cs_			 (s3_cs_),				  // 片选
		.as_			 (s_as_),				  // 地址选通
		.rw				 (s_rw),				  // 读/写
		.addr			 (s_addr[`UartAddrPosit]),  // 地址
		.wr_data		 (s_wr_data),			  // 写入数据
		.rd_data		 (s3_rd_data),			  // 读取数据
		.rdy_			 (s3_rdy_),				  // 就绪
		/********** 中断 **********/
		.irq_rx			 (irq_uart_rx),			  // 接收结束中断
		.irq_tx			 (irq_uart_tx),			  // 发送结束中断
		/********** 通用异步收发传输器送接收信号	**********/
		.rx				 (uart_rx),				  // 通用异步收发传输器接收信号
		.tx				 (uart_tx)				  // 通用异步收发传输器发发送号
	);
`else				  // 通用异步收发传输器未被分配
	assign s3_rd_data  = `WORD_DATA_W'h0;
	assign s3_rdy_	   = `DISABLE_;
	assign irq_uart_rx = `DISABLE;
	assign irq_uart_tx = `DISABLE;
`endif

	/********** 总线从属 4 : 通用输入输出端口 **********/
`ifdef IMPLEMENT_GPIO // 分配至通用输入输出端口
	gpio gpio (
		/********** 时钟 & 复位 **********/
		.clk			 (clk),					 // 时钟
		.reset			 (reset),				 // 复位
		/********** 总线信号 **********/
		.cs_			 (s4_cs_),				 // 片选
		.as_			 (s_as_),				 // 地址选通
		.rw				 (s_rw),				 // 读/写
		.addr			 (s_addr[`GpioAddrPosit]), // 地址
		.wr_data		 (s_wr_data),			 // 写入数据
		.rd_data		 (s4_rd_data),			 // 读取数据
		.rdy_			 (s4_rdy_)				 // 就绪
		/********** 通用输入输出端口 **********/
`ifdef GPIO_IN_CH	 // 输入端口分配
		, .gpio_in		 (gpio_in)				 // 输入端口
`endif
`ifdef GPIO_OUT_CH	 // 输出端口分配
		, .gpio_out		 (gpio_out)				 // 输出端口
`endif
`ifdef GPIO_IO_CH	 // 输入输出端口分配
		, .gpio_io		 (gpio_io)				 // 输入输出端口
`endif
	);
`else				  // 通用输入输出端口未被分配
	assign s4_rd_data = `WORD_DATA_W'h0;
	assign s4_rdy_	  = `DISABLE_;
`endif

	/********** 总线从属 5 : 未分配 **********/
	assign s5_rd_data = `WORD_DATA_W'h0;
	assign s5_rdy_	  = `DISABLE_;
  
	/********** 总线从属 6 : 未分配 **********/
	assign s6_rd_data = `WORD_DATA_W'h0;
	assign s6_rdy_	  = `DISABLE_;
  
	/********** 总线从属 7 : 未分配 **********/
	assign s7_rd_data = `WORD_DATA_W'h0;
	assign s7_rdy_	  = `DISABLE_;

	/********** 总线 **********/
	bus bus (
		/********** 时钟 & 复位 **********/
		.clk			 (clk),					 // 时钟
		.reset			 (reset),				 // 异步复位
		/********** 总线主控信号 **********/
		// 总线主控共享信号
		.m_rd_data		 (m_rd_data),			 // 读取数据
		.m_rdy_			 (m_rdy_),				 // 就绪
		// 总线主控0
		.m0_req_		 (m0_req_),				 // 总线请求
		.m0_addr		 (m0_addr),				 // 地址
		.m0_as_			 (m0_as_),				 // 地址选通
		.m0_rw			 (m0_rw),				 // 读/写
		.m0_wr_data		 (m0_wr_data),			 // 写入数据
		.m0_grnt_		 (m0_grnt_),			 // 总线允许
		// 总线主控1
		.m1_req_		 (m1_req_),				 // 总线请求
		.m1_addr		 (m1_addr),				 // 地址
		.m1_as_			 (m1_as_),				 // 地址选通
		.m1_rw			 (m1_rw),				 // 读/写
		.m1_wr_data		 (m1_wr_data),			 // 写入数据
		.m1_grnt_		 (m1_grnt_),			 // 总线允许
		// 总线主控2
		.m2_req_		 (m2_req_),				 // 总线请求
		.m2_addr		 (m2_addr),				 // 地址
		.m2_as_			 (m2_as_),				 // 地址选通
		.m2_rw			 (m2_rw),				 // 读/写
		.m2_wr_data		 (m2_wr_data),			 // 写入数据
		.m2_grnt_		 (m2_grnt_),			 // 总线允许
		// 总线主控3
		.m3_req_		 (m3_req_),				 // 总线请求
		.m3_addr		 (m3_addr),				 // 地址
		.m3_as_			 (m3_as_),				 // 地址选通
		.m3_rw			 (m3_rw),				 // 读/写
		.m3_wr_data		 (m3_wr_data),			 // 写入数据
		.m3_grnt_		 (m3_grnt_),			 // 总线允许
		/********** 总线从属信号 **********/
		// 总线从属共享信号
		.s_addr			 (s_addr),				 // 地址
		.s_as_			 (s_as_),				 // 地址选通
		.s_rw			 (s_rw),				 // 读/写
		.s_wr_data		 (s_wr_data),			 // 写入数据
		// 总线从属0
		.s0_rd_data		 (s0_rd_data),			 // 读取数据
		.s0_rdy_		 (s0_rdy_),				 // 就绪
		.s0_cs_			 (s0_cs_),				 // 片选
		// 总线从属1
		.s1_rd_data		 (s1_rd_data),			 // 读取数据
		.s1_rdy_		 (s1_rdy_),				 // 就绪
		.s1_cs_			 (s1_cs_),				 // 片选
		// 总线从属2
		.s2_rd_data		 (s2_rd_data),			 // 读取数据
		.s2_rdy_		 (s2_rdy_),				 // 就绪
		.s2_cs_			 (s2_cs_),				 // 片选
		// 总线从属3
		.s3_rd_data		 (s3_rd_data),			 // 读取数据
		.s3_rdy_		 (s3_rdy_),				 // 就绪
		.s3_cs_			 (s3_cs_),				 // 片选
		// 总线从属4
		.s4_rd_data		 (s4_rd_data),			 // 读取数据
		.s4_rdy_		 (s4_rdy_),				 // 就绪
		.s4_cs_			 (s4_cs_),				 // 片选
		// 总线从属5
		.s5_rd_data		 (s5_rd_data),			 // 读取数据
		.s5_rdy_		 (s5_rdy_),				 // 就绪
		.s5_cs_			 (s5_cs_),				 // 片选
		// 总线从属6
		.s6_rd_data		 (s6_rd_data),			 // 读取数据
		.s6_rdy_		 (s6_rdy_),				 // 就绪
		.s6_cs_			 (s6_cs_),				 // 片选
		// 总线从属7
		.s7_rd_data		 (s7_rd_data),			 // 读取数据
		.s7_rdy_		 (s7_rdy_),				 // 就绪
		.s7_cs_			 (s7_cs_)				 // 片选
	);

endmodule

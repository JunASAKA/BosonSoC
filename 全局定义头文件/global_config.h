/*--------全局可变参数用头文件--------*/

`ifndef __GLOBAL_CONFIG_HEADER__
	`define __GLOBAL_CONFIG_HEADER__	// 包含文件防范

//------------------------------------------------------------------------------
// 设定项目
//------------------------------------------------------------------------------
	`define TARGET_DEV_Boson_EV_BOARD	// Boson_EvBoard

	`define NEGATIVE_RESET				// 低电平激活

	`define POSITIVE_MEMORY				// 高电平激活

	`define IMPLEMENT_TIMER				// 计时器
	`define IMPLEMENT_UART				// 通用异步收发传输器
	`define IMPLEMENT_GPIO				// 通用输入输出端口

//------------------------------------------------------------------------------
// 根据设置生成参数
//------------------------------------------------------------------------------
	/********** 复位信号极性 *********/
	// Active Low
	`ifdef POSITIVE_RESET
		`define RESET_EDGE	  posedge	// 复位信号边沿
		`define RESET_ENABLE  1'b1		// 复位有效
		`define RESET_DISABLE 1'b0		// 复位无效
	`endif
	// Active High
	`ifdef NEGATIVE_RESET
		`define RESET_EDGE	  negedge	// 复位信号边沿
		`define RESET_ENABLE  1'b0		// 复位无效
		`define RESET_DISABLE 1'b1		// 复位有效
	`endif

	/********** 内存控制信号极性 *********/
	// Actoive High
	`ifdef POSITIVE_MEMORY
		`define MEM_ENABLE	  1'b1		// 内存有效
		`define MEM_DISABLE	  1'b0		// 内存无效
	`endif
	// Active Low
	`ifdef NEGATIVE_MEMORY
		`define MEM_ENABLE	  1'b0		// 内存无效
		`define MEM_DISABLE	  1'b1		// 内存有效
	`endif

`endif

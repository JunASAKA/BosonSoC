/*--------全局参数用头文件--------*/
`ifndef __STDDEF_HEADER__
    `define __STDDEF_HEADER__

//电平有关
    `define HIGH 1'b1
    `define LOW 1'b0

//是否有效有关
    `define DISABLE 1'b0
    `define ENABLE 1'b1
    `define DISABLE_ 1'b1   //负逻辑
    `define ENABLE_ 1'b0    //负逻辑

//读写有关
    `define READ 1'b1
    `define WRITE 1'b0

//数据总线-----------------------------
    `define LSB 0   //最低有效位
//字节
    `define BYTE_DATA_W 8
    `define BYTE_MSB 7
    `define ByteDataBus 7:0
//字
    `define WORD_DATA_W 32  //CPU能处理的数据宽度称为字<==>该CPU设计为32位CPU
    `define WORD_MSB 31
    `define WordDataBus 31:0

//地址总线-----------------------------
//字地址
    `define WORD_ADDR_W 30
    `define WORD_ADDR_MSB 29
    `define WordAddrBus 29:0
//字节偏移
    `define BYTE_OFFSET_W 2
    `define ByteOffsetBus 1:0
//各种位置
    `define WordAddrPosit 31:2
    `define ByteOffsetPosit 1:0
//字边界
    `define BYTE_OFFSET_WORD 2'b00

`endif
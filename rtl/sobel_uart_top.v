module sobel_uart_top (
	input		wire			sys_clk			,
	input 		wire	 		sys_rst_n		,
	input		wire    		rx				,

	output 		wire         	tx	
);

wire     	 	 pi_flag;
wire	[7:0]	 pi_data;
wire             po_flag;
wire    [7:0]    po_data;



//接口模块的例化

uart_rx uart_rx_inst
(
.sys_clk   (sys_clk 	)   , //系统时钟50MHz
.sys_rst_n (sys_rst_n   )     , //全局复位
.rx  	   (rx 			)		, //串口接收数据
.po_data   (pi_data 	)	, //串转并后的数据
.po_flag   (pi_flag 	)	  //串转并后的数据有效标志信号
);    

sobel sobel_inst
(
.sys_clk (sys_clk), //输入系统时钟,频率50MHz
.sys_rst_n (sys_rst_n ), //复位信号,低有效
.pi_data (pi_data ), //rx 传入的数据信号
.pi_flag (pi_flag ), //rx 传入的标志信号
.po_data (po_data ), //fifo 加法运算后的信号
.po_flag (po_flag ) //输出标志信号
);

 uart_tx uart_tx_inst
(
.sys_clk (sys_clk ), //系统时钟50MHz
.sys_rst_n (sys_rst_n ), //全局复位
.pi_data (po_data ), //并行数据
.pi_flag (po_flag ), //并行数据有效标志信号
.tx (tx ) //串口发送数据
);  
endmodule
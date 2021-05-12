module sobel (
	input       wire            sys_clk     ,
	input       wire            sys_rst_n   ,
    input       wire   [7:0]    pi_data     ,
    input       wire            pi_flag     ,

    output      reg    [7:0]    po_data     ,
    output      reg             po_flag  	
);
//****************** Parameter and Internal Signal *******************
parameter COL_MAX = 8'd4 ; //图片宽度 列数
parameter ROW_MAX = 8'd6 ; //图片长度 行数


//--------------中间变量赋值-------------------
reg       [7:0]     cnt_col         ; 
reg       [7:0]     cnt_row         ; 

reg                 wr_en1          ;
reg       [7:0]     data_in1        ;   
reg                 rd_en           ;
wire      [7:0]     data_out1       ;

 
reg       [7:0]     data_in2        ;
reg                 wr_en2          ;  
wire      [7:0]     data_out2       ;

reg                 rd_en_reg       ;
reg       [7:0]     data_out3       ;

reg       [7:0]     data_out1_reg   ;
reg       [7:0]     data_out2_reg   ;
reg       [7:0]     data_out3_reg   ;

reg       [7:0]     data_out1_reg2  ;
reg       [7:0]     data_out2_reg2  ;
reg       [7:0]     data_out3_reg2  ;

reg                 gx_gy_flag      ;
reg                 out_flag        ;
reg       [7:0]     out_flag_cnt    ; 
reg       [8:0]     g_x             ;
reg       [8:0]     g_y             ;
reg       [7:0]     g_xy            ;
reg                 gx_gy_flag_reg  ;
reg                 gx_gy_flag_reg2 ;						

//行计数信号cnt_col
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		cnt_col <= 8'd0; // reset		
	end
	else if ((cnt_col == COL_MAX-1'd1)&&(pi_flag == 1'd1)) begin
		cnt_col <= 8'd0;
	end
	else if (pi_flag == 1'd1) begin
		cnt_col <= cnt_col + 8'd1;
	end
	else begin
		cnt_col <= cnt_col;
	end
end

//列计数信号cnt_row
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		cnt_row <=  8'd0; // reset		
	end
	else if ((cnt_col == COL_MAX-1'd1)&&(pi_flag == 1'd1)) begin
		cnt_row <= cnt_row + 8'd1;
	end
end
//wr_en1 第一个fifo 的写信号 
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		wr_en1 <= 1'd0; // reset	
	end
	else if ((cnt_row == 8'd0)&&(pi_flag == 1'd1)) begin
		wr_en1 <= 1'd1;
	end
	else if ((cnt_row !== 8'd0)&&(cnt_row !== 8'd1)) begin
		wr_en1 <= rd_en_reg;
	end
	else begin
		wr_en1 <= 1'd0;
	end	

end

//wr_en2 第二个FIFO 的写入信号
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		 wr_en2 <= 1'd0; // reset		
	end
	/*else if ((cnt_row == ROW_MAX-2)&&(cnt_col == COL_MAX-1)&&(pi_flag == 1'd1)) begin
		 wr_en2 <= 1'd0;
	end*/
	else if ((cnt_row == ROW_MAX-1)||(cnt_row == ROW_MAX)) begin
		 wr_en2 <= 1'd0;
	end
	else if ((cnt_row !== 8'd0)&&(pi_flag == 1'd1)) begin
		 wr_en2 <= 1'd1;
	end
	else begin
		 wr_en2 <= 1'd0;
	end
end

//data_in1 第一个FIFO的输入信号,前半步实现后半部未实现
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		data_in1 <= 8'd0; // reset	
	end
	else if((cnt_row == 8'd1)&&(cnt_col == 8'd0)&&(pi_flag == 1'd1)) begin
		data_in1 <= 8'd0;
	end
	else if ((cnt_row == 8'd0)||((cnt_row == 8'd1)&&(cnt_col == 8'd0))) begin
		data_in1 <= pi_data;
	end
	else if ((cnt_row !== 8'd1)&&(cnt_row !== 8'd0)) begin
		data_in1 <= data_out2;
	end
	else begin
		data_in1 <= 8'd0;
	end
end

//data_in2 第二个fifo的输入信号
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		data_in2 <= 8'd0;// reset		
	end	
	else if((cnt_row == 8'd1)&&(cnt_col == 8'd0)&&(pi_flag == 1'd0)) begin
	    data_in2 <= 8'd0;   	
	end        
	else if (cnt_row !== 8'd0) begin
		data_in2 <= pi_data;
	end
	else begin
		data_in2 <= data_in2;
	end
end

//rd_en读使能信号两个fifo共用一个
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		rd_en <= 1'd0; // reset		
	end
	else if ((cnt_row == 8'd1)||(cnt_row == 8'd0)) begin
		rd_en <= 1'd0; 
	end
	else begin
		rd_en <= pi_flag;
	end
end

//读使能信号的寄存位rd_en_reg
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
	   rd_en_reg <= 1'd0;	// reset		
	end
	else begin
		rd_en_reg <= rd_en;
	end
end

//数据对齐位data_out3
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		data_out3 <= 8'd0; // reset
		
	end
	else if (cnt_row == 8'd1) begin
		data_out3 <= 8'd0;
	end
	else if (cnt_row == 8'd0) begin
		data_out3 <= 8'd0;
	end
	else if ((cnt_row == 8'd2)&&(cnt_col == 8'd0)) begin
		data_out3 <= 8'd0;
	end
	else begin
		data_out3 <= data_in2;
	end
end

//dataout1寄存器1配置
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		data_out1_reg <= 8'd0; // reset		
	end
	else if (rd_en) begin
		data_out1_reg <= data_out1;
	end
	else begin
		data_out1_reg <= data_out1_reg;
	end
end

//dataout2寄存器1配置
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		data_out2_reg <= 8'd0; // reset		
	end
	else if (rd_en) begin
		data_out2_reg <= data_out2;
	end
	else begin
		data_out2_reg  <= data_out2_reg;
	end
end
//dataout3寄存器1配置
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		data_out3_reg <= 8'd0; // reset
		
	end
	else if (rd_en) begin
		data_out3_reg <= data_out3;
	end
	else begin
		data_out3_reg <= data_out3_reg;
	end
end

//dataout1寄存器2配置
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		data_out1_reg2 <= 8'd0; // reset		
	end
	else if (rd_en) begin
		data_out1_reg2 <= data_out1_reg;
	end
	else begin
		data_out1_reg2 <= data_out1_reg2;
	end
end

//dataout2寄存器2配置
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		data_out2_reg2 <= 8'd0; // reset		
	end
	else if (rd_en) begin
		data_out2_reg2 <= data_out2_reg ;
	end
	else begin
		data_out2_reg2  <= data_out2_reg2;
	end
end
//dataout3寄存器2配置
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		data_out3_reg2 <= 8'd0; // reset
		
	end
	else if (rd_en) begin
		data_out3_reg2 <= data_out3_reg ;
	end
	else begin
		data_out3_reg2 <= data_out3_reg2;
	end
end
//形成gx_gy_flag的前提out_flag信号的形成
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		out_flag <= 1'd0; // reset		
	end
	else if ((cnt_row == 8'd0)||(cnt_row == 8'd1)) begin
		out_flag <= 1'd0;
	end
	else if ((cnt_row == 8'd2)&&(cnt_col == 8'd1)) begin
		out_flag <= 1'd0;
	end
	else if ((cnt_row == 8'd2)&&(cnt_col == 8'd0)) begin
		out_flag <= 1'd0;
	end
	else begin
		out_flag <= pi_flag;
	end
end

//gx_gy计数器
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		out_flag_cnt <= 1'd0; // reset		
	end
	else if ((out_flag_cnt == COL_MAX-1)&&(out_flag == 1'd1)) begin
		out_flag_cnt <= 1'd0 ;
	end
	else if (out_flag == 8'd1) begin
		out_flag_cnt <= out_flag_cnt + 8'd1;
	end
	else begin
		out_flag_cnt <= out_flag_cnt;
	end
end
//gx_gy标志信号 gx_gy_flag
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		gx_gy_flag <= 1'd0; // reset
	end
	else if((out_flag_cnt == COL_MAX-1)||(out_flag_cnt == COL_MAX-2)) begin
		gx_gy_flag <= 1'd0;
	end
	else begin
		gx_gy_flag <= out_flag;
	end
end
//g_x值的运算

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		g_x <= 9'd0; // reset
		
	end
	else if (gx_gy_flag == 1'd1) begin
		g_x <= (data_out1- data_out1_reg2)+((data_out2 - data_out2_reg2)<<1)+(data_out3-data_out3_reg2);
	end
	else begin
		g_x <= g_x;
	end
end
//g_y值的计算
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		g_y <= 9'd0; // reset
		
	end
	else if (gx_gy_flag == 1'd1) begin
		g_y <= (data_out1_reg2-data_out3_reg2)+((data_out1_reg - data_out3_reg)<<1)+(data_out1 - data_out3);
	end
	else begin
		g_y <= g_y;
	end
end
//对gx_gy_flag信号打一拍 形成gx_gy_flag_reg
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		gx_gy_flag_reg <= 1'd0; // reset
		
	end
	else  begin
		gx_gy_flag_reg <= gx_gy_flag;
	end
end


//g_XY值的计算用两个绝对值相加代替平方和开根号不再调用ip_core
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		g_xy <= 8'd0 ;// reset
	end
	else if ((g_x[8] == 1'b1)&&(g_y[8] == 1'b1)&&(gx_gy_flag_reg == 1'b1)) begin
		g_xy <= (~g_x[7:0] + 1'b1) + (~g_y[7:0] +1'b1);
	end
	else if ((g_x[8] == 1'b1)&&(g_y[8] == 1'b0)&&(gx_gy_flag_reg == 1'b1)) begin
		g_xy <= (~g_x[7:0] + 1'b1) + (g_y[7:0]);
	end
	else if ((g_x[8] == 1'b0)&&(g_y[8] == 1'b1)&&(gx_gy_flag_reg == 1'b1)) begin
		g_xy <= (g_x[7:0]) + (~g_y[7:0] +1'b1);
	end
	else if ((g_x[8] == 1'b0)&&(g_y[8] == 1'b0)&&(gx_gy_flag_reg == 1'b1)) begin
		g_xy <= (g_x[7:0] ) + (g_y[7:0] );
	end
//输出标志信号
end
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		gx_gy_flag_reg2 <= 1'd0; // reset		
	end
	else  begin
		gx_gy_flag_reg2 <= gx_gy_flag_reg;
	end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		po_flag <= 1'd0; // reset
		
	end
	else  begin
		po_flag <= gx_gy_flag_reg2;
	end
end

//输出信号
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		po_data <= 8'd0; // reset
		
	end
	else if (gx_gy_flag_reg2 == 1'd1) begin
		po_data <= g_xy;
	end
end



//-------------fifo_pic_inst1--------------ip_core调用
fifo fifo_inst1
(
.clock  (sys_clk   ), 
.data   (data_in1  ), 
.wrreq  (wr_en1    ), 
.rdreq  (rd_en     ), 
.q      (data_out1 ) 
);

//-------------fifo_pic_inst2--------------
fifo fifo_inst2
(
.clock (sys_clk   ), 
.data  (data_in2  ), 
.wrreq (wr_en2    ), 
.rdreq (rd_en     ), 
.q     (data_out2 )  
);   
/*
//测试使用的伪输出
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		po_data <= 8'd0; // reset
		
	end
	else  begin
		po_data <= 8'd1;
	end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n) begin
		po_flag <= 1'd0; // reset
		
	end
	else   begin
		po_flag <= 1'd1;
	end
end

*/


endmodule
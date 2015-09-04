//spi master IP核
//第一个下降沿读入数据
//使能上升沿将写入的数据放入缓冲区
`define SPI_LEN 24
module SPI_MASTER( 
		  input clk,
        input [`SPI_LEN-1:0]data_in,
		  input rst_n,
		  input en,
		  output reg sclk,dout,sync_n
		  );
   //define state
   parameter [1:0] IDLE=2'b00,SEND=2'b01,SEND_n = 2'b10,END = 2'b11;
   reg [1:0] current_state=IDLE;
	reg [1:0] next_state=IDLE;
	reg [4:0] counter=`SPI_LEN;
	reg [`SPI_LEN-1:0] data_in_save;
	//状态转换
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			current_state<= IDLE;
		else
			current_state<= next_state;
		end
	//第二个进程，组合逻辑always模块，描述状态转移条件判断
	always@(current_state or sclk  or rst_n or en)begin
		next_state = IDLE;
		if(!rst_n)
			next_state = IDLE;
		else begin
			case(current_state)
				//空闲状态
				IDLE:begin
					//外部使能 进入发送
					if(en)begin
						next_state = SEND_n;
						end
					else
						next_state = IDLE;
					end
				SEND:begin
					if(counter==0)
						next_state=END;
					else if(!sclk)//正在发送，进入下一状态
						next_state = SEND_n;
					else
						next_state = SEND;
					end
				SEND_n:begin
					if(sclk)
						next_state = SEND;
					else
						next_state = SEND_n;
					end
				END:begin
					if(counter>=10)
						next_state=IDLE;
					else
						next_state = END;
					end
				default:next_state = IDLE;
				endcase
			end
		end
	//第三个进程，同步时序always模块，格式化描述次态寄存器输出
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			end
		else begin
			case(next_state)
				IDLE: begin
					data_in_save <= data_in;
					counter <=`SPI_LEN;
					sclk <= 1'b1;
					sync_n <= 1'b1;
					end
				SEND:begin
					sclk <= 1'b0;
					counter <= counter-1;
					end
				SEND_n:begin
					sclk <= 1'b1;
					dout <= data_in_save[counter-1];
					sync_n <= 1'b0;
					end
				END:begin
					sclk <= 1'b1;
					sync_n <= 1'b1;
					counter <= counter+1;
					end
				default:begin
					end
				endcase
			end
		end
	endmodule 
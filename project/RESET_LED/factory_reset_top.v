//LED PWM——测试
//占空比改变按键
//输入时钟 复位脚
//输出 8个led
module factory_reset_top(input key_d,
								 input clk,input reset_n,
								 output wire [7:0]LED);
//占空比
reg [9:0] duty = 8;
//分频器输出
wire clk_div_o;
//加减标记
reg is_add = 1;
//分频器1
clk_div div1(
	.clk_in(clk),
	.clk_div(clk_div_o)
);
//led1
pwm_led led1(
	.clk(clk),
	.duty(duty),
	.to_LED(LED)
);
	
	//定时器更改占空比
	always@(posedge clk_div_o)begin
		if(duty <= 1)
			is_add <= 1;
		else if(duty >= 10'b1111111110)
			is_add <= 0;
		if(is_add)
			duty <= duty+1;
		else
			duty <= duty-1;
		end
endmodule
//分频器模块
module clk_div(input clk_in,output reg clk_div);
	reg [32:0] counter;
	always@(posedge clk_in)begin
		counter <= counter+1;
		if(counter >= 20000)begin
			counter <= 0;
			clk_div <= ~clk_div;
			end
		end
endmodule
//pwm模块
module pwm_led(input [9:0] duty,
					input clk,
					output reg [7:0] to_LED);
	reg[9:0] counter;
	always@(posedge clk)begin
		counter <= counter+1;
		if(duty>counter)
			to_LED <= 0;
		else
			to_LED <= 8'b11111111;
		end
endmodule 
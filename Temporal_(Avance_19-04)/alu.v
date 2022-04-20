`timescale 1ns / 1ps


module alu(
    input [2:0] portA,     //Pines para ingresar el operando A (Multiplicando)
    input [2:0] portB,     //Pines para ingresar el operando B (Multiplicador)
    input [1:0] opcode,    //Pines para ingresar el op-code y que la ALU sepa que operación ejecutar
    output [0:6] sevenseg, //Pines para asignar a los 7 segmentos
    output [3:0] anode,    //Pines para multiplexar los ánodos
    input clk,             //Pin para sincronizar con el reloj
    input rst              //Pin para habilitar el reset
 );

// Declaraci�n de salidas de cada bloque
wire [3:0] sal_sh_r;   //Salidas para el bloque desp. der.
wire [3:0] sal_sh_l;   //Salidas para el bloque desp. izq.
wire [3:0] sal_div;    //Salidas para el bloque divisor
wire [5:0] sal_isZero; //Salidas para el bloque comparador


// Declaraci�n de las entradas init de cada bloque (Las señales de control para habilitar una u otra operación de la ALU)
reg [3:0] init;
wire init_sh_r;
wire init_sh_l;
wire init_isZero;
wire init_div;

//

assign init_sh_r= init[0];
assign init_sh_l=init[1];
assign init_isZero=init[2];
assign init_div=init[3];

reg [15:0]int_bcd; //Registro que se pasará 4 bits por número al módulo display

//wire [3:0] operacion;

// descripci�n del decodificacion de operaciones (Según el valor de opcode se hará una u otra operación)
always @(*) begin
	case(opcode)
		2'b00: init<=1;
		2'b01: init<=2;
		2'b10: init<=4;
		2'b11: init<=8;
	default:
		init <= 0;
	endcase

end
// Descripcion del miltiplexor
always @(*) begin
	case(opcode)
		2'b00: int_bcd <={12'b0,sal_sh_l};
		2'b01: int_bcd <={8'b0,sal_sh_r,4'b0};
		2'b10: int_bcd <={4'b0,sal_isZero,8'b0};
		2'b11: int_bcd <={sal_div,12'b0}};
	default:
		int_bcd <= 0;
	endcase

end


//instanciaci�n de los componentes - Agregar los shift, zero y divisi�n. Revisar funcionalidad de visualizaci�n

sh_l()
sh_r()
zero()

//Visualizaci�n - 7seg or l
display dp( .num(int_bcd), .clk(clk), .sseg(sevenseg), .an(anode), .rst(rst)); //Copiar el módulo de digital 1 que ya sirve para convertir a BCD y todo uwu

//sum4b sum(. init(init_suma),.xi({1'b0,portA}), .yi({1'b0,portB}),.sal(sal_suma));
//multiplicador mul ( .MR(portB), .MD(portA), .init(init_mult),.clk(clk), .pp(sal_mult));

endmodule

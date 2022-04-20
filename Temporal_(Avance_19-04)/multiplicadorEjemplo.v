`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    18:40:46 09/13/2019
// Design Name:
// Module Name:    multiplicador
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module multiplicador( input [2:0] MR, //Entrada que recibirá el valor de B (Multiplicador)
							 input [2:0] MD, //Entrada que recibirá el valor de A (Multiplicando)
							 input init, //Señal de control para dar inicio al multiplicador o permanecer en el estado 0 (START)
							 input clk, //Señal de reloj para sincronizar
							 output reg [5:0] pp, //El registro que guardará los Productos Parciales
							 output reg done //Señal de control para poder pasar al estado 5 (END1)
    );

reg sh; //Señal de control para habilitar el shift
reg rst; //Señal de control para fijar el Producto Parcial (PP) en 0
reg add; //Señal de control para habilitar la suma
reg [5:0] A; //Multiplicando
reg [2:0] B; //Multiplicador
wire z; //Señal de control que producirá el comparador

reg [2:0] status =0; //Almacena el estado actual de la MEF (0 a 4) (5 en total)

// bloque comparador
assign z=(B==0)?1:0; //Si B==0, el comparador se mantiene en 1, pero cuando eso no se cumpla, valdrá 0



//bloques de registros de desplazamiento para A y B
always @(posedge clk) begin

	if (rst) begin
		A = {3'b000,MD}; //Devuelve A a su posición original (En los últimos 3 LSB), es decir, reinicia el desplazamiento
		B = MR; //Mantiene B intacto
	end
	else	begin
		if (sh) begin
			A= A << 1; //Desplaza A a la izquierda
			B = B >> 1; //Desplaza B a la derecha
		end
	end

end

//bloque de add pp
always @(posedge clk) begin

	if (rst) begin
		pp =0; //Borra lo que haya en PP (Usado al inicio del funcionamiento porque el primer PP=0)
	end
	else	begin
		if (add) begin
		pp =pp+A; //Va almacenando la suma de los PP
		end
	end

end

// FSM
parameter START =0,  CHECK =1, ADD =2, SHIFT =3, END1 =4;

always @(posedge clk) begin
	case (status)
	START: begin //Inicia el estado 0
		sh=0; //Primero configura los valores de las señales de control del siguiente estado para que al entrar a este todo funcione OK
		add=0;
		if (init) begin
			status=CHECK; //Una vez se le da la orden de comenzar, pasa al estado 1
			done =0;
			rst=1; //Hace reset para que el PP inicial sea cero y para asegurar que el valor de A no tenga un desplazamiento previo
		end
		end
	CHECK: begin
		done=0; //Define los valores para las señales de control tal cual quedó en el diagrama de estados
		rst=0;
		sh=0;
		add=0;
		if (B[0]==1) //Toma la decisión para saber si debe sumar o solo desplazar (Pasar a estado 2 o estado 3)
			status=ADD;
		else
			status=SHIFT;
		end
	ADD: begin
		done=0; //Si pasa al estado 2, define los valores como se indica en el diagrama de estados
		rst=0;
		sh=0;
		add=1;
		status=SHIFT; //Y al finalizar dicha "inicialización" de valores, pasa al estado 3
		end
	SHIFT: begin
		done=0; //Define los valores para las señales de control tal y como se hizo en anteriores estados
		rst=0;
		sh=1;
		add=0;
		if (z==1) //Según lo que indique el comparador al final de definir los valores, se procederá a repetir el estado 1, o seguir al 4
			status=END1;
		else
			status=CHECK;
		end
	END1: begin
		done =1; //Acá se definen los valores del diagrama de estados y se pasa inmediatamente de nuevo a esperar un init que le de inicio al multiplicador
		rst =0;
		sh =0;
		add =0;
		status =START;
	end
	 default:
		status =START;
	endcase

end


endmodule

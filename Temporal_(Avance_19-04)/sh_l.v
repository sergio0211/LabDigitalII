`timescale 1ns / 1ps
module sh_l(
  input [2:0] portA,     //Pines para ingresar el operando (Se me ocurre que funcione el A para sll y el B para srl para no enredarse tanto con un pin que multiplexe A o B a la salida)
  input init_sh_l,       //Pin para habilitar o no este módulo (Asignar a pulsador para que refresque y no se quede en 1)
  input clk,             //Pin para sincronizar con el reloj
  input rst,             //Pin para volver al dato sin corrimientos
  output [3:0] sal_sh_l  //Pines para extraer lo que retorna este módulo y usarlo en el top-module
);

reg [3:0] A; //Registro que almacenará el número desplazado
assign sal_sh_l = A;

always @ (posedge clk) begin //Comentar esto para sintetizar y luego descomentarlo para simular
if (rst) A = {1'b0,portA}; //Devuelve A a su posición original (En los últimos 3 LSB), es decir, reinicia el desplazamiento
end

always @ (posedge init_sh_l) begin
  A = A << 1; //Desplaza A a la izquierda
end
endmodule

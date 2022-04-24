module divisor( input [2:0] DV,             //Entrada que recibirá el valor de DV (Dividendo)
							  input [2:0] DR,             //Entrada que recibirá el valor de DR (Divisor)
								input init,                 //Señal de control xd
							 	input clk,                 //Señal de reloj para sincronizar
							 	output reg [5:0] dvo,      //El registro que guardará la cuenta de los Cocientes Parciales
							 	output reg done            //Señal de control para poder pasar al estado final
    );


//Signals

reg sh; 					   //Señal de control para habilitar el shift

reg lda;             //Hace la resta entre A y el divisor
reg N;               //Cuenta los bits del dividendo. Empieza en el valor de los bits del dividendo y termina en 0.
reg msb;             //bit mas siginificativo. Es 1 o 0
reg add; 					   //Señal de control para habilitar la suma (complemento a 2)
reg [2:0] A; 			   //Dividendo
reg [2:0] B; 			   //Divisor
wire z; 					   //Señal de control que producirá el comparador. Informa a la unidad de control si la entrada B es igual a 0 (Done).

reg [2:0] status =0; //Almacena el estado actual de la MEF (0 a 4) (5 en total)

// bloque comparador
assign z=(N==0)?1:0;      //Si N==0, el comparador se mantiene en 1, pero cuando eso no se cumpla, valdrá 0

//bloque complemento a 2
C2DR = ~DR+1;


//bloques de registros de desplazamiento para A (dividendo)
always @(posedge clk) begin

	if (init) begin
		A = {5'b00000,DV[5]};    //Empieza en el bit más significativo del diviendo. Solo toma su MSB
		B = DR;                 //Mantiene B intacto - Debe ser el complemento a 2 de B
	end
	else	begin
		if (sh) begin
			A= A << 1;   //Desplaza A a la izquierda
			B = B;
		end
	end
end

//bloque de add dv0
always @(posedge clk) begin

	if (init) begin
		dv0 = 0;                        //Borra lo que haya en dvo. Vacía el vector.
	end
	else	begin
		if (add) begin                  //Se empieza a llenar el vector
			if (A<DR)
				dv0 = dv0 + 0;             //suma un 0 al resultado final
			else
				dv0 = dv0 + 1;             //suma un 1 al resultado final
				A = A + C2DR;              //Ahora, el nuevo dividendo será el resultado obtenido + el nuevo valor de bit de A
	 end
	 N = N-1;                         //El proceso termina cuando N=0;
	end
 end
end

// FSM
parameter START =0,  SHIFT_DEC =1,  CHECK =2, ADD =3, , END1 =4;

always @(posedge clk) begin
	case (status)
	START: begin                    //Inicia el estado 0
		sh=0;                         //Primero configura los valores de las señales de control del siguiente estado para que al entrar a este todo funcione OK
		lda=0;
		if (init) begin
			status=SHIFT_DEC;              //Una vez se le da la orden de comenzar, pasa al estado 1
			done=0;
			init=1;                     //Hace reset para que el PP inicial sea cero y para asegurar que el valor de A no tenga un desplazamiento previo
			dec=0;
			dv0=0;
		end
		end


		SHIFT_DEC: begin
			done=0;                   //Define los valores para las señales de control tal y como se hizo en anteriores estados
			init=0;
			sh=1;
			lda=0;
			dv0=dv0;
			dec=1;
			end

	CHECK: begin                   //Inicio del estado 2
		done=0;                      //Define los valores para las señales de control tal cual quedó en el diagrama de estados
		rst=0;
		sh=0;
		add=0;
		if (z==1)                //Según lo que indique el comparador al final de definir los valores, se procederá a repetir el estado 1, o seguir al 4
			status=END1;
		else if (A[5]==1)                 //Mira el MSB del resultado parcial de A (registro de cocientes parciales)
				status=SHIFT_DEC;
			else
				status=ADD;
			end
		end


	ADD: begin                    //Inicio estado 3
			done=0;                   //Define los valores para las señales de control tal y como se hizo en anteriores estados
			init=0;
			sh=0;
			lda=1;
			dv0=1;
			dec=0;
			if (z==1)
				status=END1;
			else
				status=SHIFT_DEC;
			end
		end


	END1: begin
			done=1;                   //Define los valores para las señales de control tal y como se hizo en anteriores estados
			init=0;
			sh=0;
			lda=0;
			dv0=0;
			dec=0;
	end
	 default:
		status =START;
	endcase
end
endmodule



module div_int #(parameter WIDTH=4) (
    input wire logic clk,
    input wire logic start,          // start signal
    output     logic busy,           // calculation in progress
    output     logic valid,          // quotient and remainder are valid
    output     logic dbz,            // divide by zero flag
    input wire logic [WIDTH-1:0] x,  // dividend
    input wire logic [WIDTH-1:0] y,  // divisor
    output     logic [WIDTH-1:0] q,  // quotient
    output     logic [WIDTH-1:0] r   // remainder
    );

    logic [WIDTH-1:0] y1;            // copy of divisor
    logic [WIDTH-1:0] q1, q1_next;   // intermediate quotient
    logic [WIDTH:0] ac, ac_next;     // accumulator (1 bit wider)
    logic [$clog2(WIDTH)-1:0] i;     // iteration counter

    always_comb begin
        if (ac >= {1'b0,y1}) begin
            ac_next = ac - y1;
            {ac_next, q1_next} = {ac_next[WIDTH-1:0], q1, 1'b1};
        end else begin
            {ac_next, q1_next} = {ac, q1} << 1;
        end
    end

    always_ff @(posedge clk) begin
        if (start) begin
            valid <= 0;
            i <= 0;
            if (y == 0) begin  // catch divide by zero
                busy <= 0;
                dbz <= 1;
            end else begin  // initialize values
                busy <= 1;
                dbz <= 0;
                y1 <= y;
                {ac, q1} <= {{WIDTH{1'b0}}, x, 1'b0};
            end
        end else if (busy) begin
            if (i == WIDTH-1) begin  // we're done
                busy <= 0;
                valid <= 1;
                q <= q1_next;
                r <= ac_next[WIDTH:1];  // undo final shift
            end else begin  // next iteration
                i <= i + 1;
                ac <= ac_next;
                q1 <= q1_next;
            end
        end
    end
endmodule

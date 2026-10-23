`timescale 1ns/1ns
module multiplier_bn_booth #(
   parameter n = 31
)(
//---------------------Port directions and deceleration
   input clk,  
   input start,
   input [n-1 : 0]A,
   input [n-1 : 0]B,
   output reg [2*n - 1 : 0]Product,
   output ready
    );



//----------------------------------------------------


//--------------------------------- register deceleration
reg [n:0] Multiplicand ;
reg [n-1:0]  Multiplier;
reg [6:0]  counter;
reg s = 1'b0;
reg [n:0]negative_multiplicand;
//-----------------------------------------------------

//----------------------------------- wire deceleration
wire [2:0]product_write_enable;
//-------------------------------------------------------

//------------------------------------ combinational logic
assign product_write_enable = n%2 == 0? {Product[1 : 0] , s} : counter < (n-1)/2 ? {Product[1 : 0] , s} : {Product[0] , Product[0] , s};
assign ready = counter[3];
//-------------------------------------------------------

//------------------------------------- sequential Logic
always @ (posedge clk)

   if(start) begin
      counter <= 0 ;
      s <= 0;
      Multiplier <= B;
      Product <= {1'b0,1'b0,1'b0,1'b0,1'b0,B};
      Multiplicand <= {A[n-1],A[n-1:0]} ;
      negative_multiplicand <= ~{A[n-1],A}+1;
   end

   else if(counter < n/2 && n%2 == 0) begin
         counter <= counter + 1;
         s <= Product[1];
         Product = Product >> 2;
         Product[2*n-1] = Product[2*n-3];
         Product[2*n-2] = Product[2*n-3];

         if(product_write_enable == 3'b001 || product_write_enable == 3'b010)begin
            Product[2*n-1:n - 2] <= {Multiplicand[n] , Multiplicand} + {Product[2*n-1 : n-2]};

         end
         if(product_write_enable == 3'b110 || product_write_enable == 3'b101)begin
            Product[2*n-1:n - 2] <=  {negative_multiplicand[n],negative_multiplicand} + {Product[2*n-1 : n-2]};

         end
         if(product_write_enable == 3'b011)begin
            Product[2*n-1:n - 2] <= {Multiplicand[n] , Multiplicand<<1} + {Product[2*n-1 : n-2]};

         end
         if(product_write_enable == 3'b100)begin
            Product[2*n-1:n - 2] <= {negative_multiplicand[n],negative_multiplicand<<1} + {Product[2*n-1 : n-2]};
         end
   end


   else if(counter < (n+1)/2 && n%2 == 1) begin
      counter <= counter + 1;
      if(counter < (n-1)/2)begin
         s <= Product[1];
         Product = Product >> 2;
         Product[2*n-1] = Product[2*n-3];
         Product[2*n-2] = Product[2*n-3];

         if(product_write_enable == 3'b001 || product_write_enable == 3'b010)begin
            Product[2*n-1:n - 2] <= {Multiplicand[n] , Multiplicand} + {Product[2*n-1 : n-2]};

         end
         if(product_write_enable == 3'b110 || product_write_enable == 3'b101)begin
            Product[2*n-1:n - 2] <=  {negative_multiplicand[n],negative_multiplicand} + {Product[2*n-1 : n-2]};

         end
         if(product_write_enable == 3'b011)begin
            Product[2*n-1:n - 2] <= {Multiplicand[n] , Multiplicand<<1} + {Product[2*n-1 : n-2]};

         end
         if(product_write_enable == 3'b100)begin
            Product[2*n-1:n - 2] <= {negative_multiplicand[n],negative_multiplicand<<1} + {Product[2*n-1 : n-2]};
         end

      end

      else begin
         s <= Product[0];
         Product = Product >> 1;
         Product[2*n-1] = Product[2*n-2];

         if(product_write_enable == 3'b001 || product_write_enable == 3'b010)begin
            Product[2*n-1:n - 1] <=  Multiplicand + {Product[2*n-1 : n-1]};

         end
         if(product_write_enable == 3'b110 || product_write_enable == 3'b101)begin
            Product[2*n-1:n - 1] <=  negative_multiplicand + {Product[2*n-1 : n-1]};

         end
         if(product_write_enable == 3'b011)begin
            Product[2*n-1:n - 1] <= (Multiplicand<<1) + {Product[2*n-1 : n-1]};

         end
         if(product_write_enable == 3'b100)begin
            Product[2*n-1:n - 1] <= (negative_multiplicand<<1) + {Product[2*n-1 : n-1]};
         end
      end
   end

endmodule

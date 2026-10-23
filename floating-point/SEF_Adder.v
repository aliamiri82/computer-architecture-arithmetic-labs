module fp_adder (
    input [31:0]A,
    input [31:0]B,
    output [31:0]s
);
    
wire [25:0]Fraction_A , Fraction_B; 
wire [25:0]Fraction_Aq ,Fraction_Bq;
wire [22:0]Fraction_C;
wire [25:0]Fraction_C_notround;
wire [7:0]Exponent_A , Exponent_B , Exponent_C;
wire [7:0]Exponent_max , Exponent_min;
wire [7:0]New_Exponent_A , New_Exponent_B;
wire [7:0]Exponent_Difference;
wire [28:0]stickyFraction_A , stickyFraction_B; 
wire [28:0]comp_Fraction_A , comp_Fraction_B , comp_Fraction_C , mag_Fracrion_C , mag_Fracrion_round;
wire [7:0]shift;
wire [25:0]Fraction_shift_A , Fraction_shift_B;
wire sign_A , sign_B , sign_C;
wire Sticky_bit;
wire secret_sticky;


///////////// get inputs
assign Exponent_A = A[30:23];
assign Exponent_B= B[30:23];
assign sign_A = A[31];
assign sign_B = B[31];
assign Fraction_Aq = Exponent_A==0? {1'b0 , A[22:0] , 2'b00} : {1'b1 , A[22:0] , 2'b00}; 
assign Fraction_Bq = Exponent_B==0? {1'b0 , B[22:0] , 2'b00} : {1'b1 , B[22:0] , 2'b00};


///////////////////////////////////////
assign New_Exponent_A = Exponent_A==0? 1 : Exponent_A;
assign New_Exponent_B = Exponent_B==0? 1 : Exponent_B;
assign Exponent_max = New_Exponent_A >= New_Exponent_B ? New_Exponent_A : New_Exponent_B;
assign Exponent_min = New_Exponent_A >= New_Exponent_B ? New_Exponent_B : New_Exponent_A;
assign Exponent_Difference = (New_Exponent_A >= New_Exponent_B) ? (New_Exponent_A - New_Exponent_B) : (New_Exponent_B - New_Exponent_A);

//////////////////////////////////////
assign Fraction_A = (New_Exponent_A >= New_Exponent_B) ? Fraction_Aq : Fraction_Aq >> Exponent_Difference;
assign Fraction_B = (New_Exponent_B >= New_Exponent_A) ? Fraction_Bq : Fraction_Bq >> Exponent_Difference;


//////////////////////////////////////Sticky Bit
assign Fraction_shift_A = Fraction_Aq << shift;
assign Fraction_shift_B = Fraction_Bq << shift;
assign shift = Exponent_Difference > 26 ? (Exponent_Difference - 26) : (26 - Exponent_Difference);
assign Sticky_bit = (New_Exponent_A > New_Exponent_B)? (Fraction_shift_B >= 1 ? 1'b1 : 1'b0 ) :
(New_Exponent_A < New_Exponent_B) ? (Fraction_shift_A >= 1 ? 1'b1 : 1'b0 ) : 1'b0;
assign secret_sticky = mag_Fracrion_C[1]|| mag_Fracrion_C[0];

//////////////////////////////////////Stick sticky
assign stickyFraction_A = (New_Exponent_A >= New_Exponent_B) ? {2'b00 ,Fraction_A ,1'b0} : {2'b00 ,Fraction_A , Sticky_bit};
assign stickyFraction_B = (New_Exponent_A >= New_Exponent_B) ? {2'b00 ,Fraction_B ,Sticky_bit} : {2'b00 ,Fraction_B , 1'b0};


/////////////////////////////////////2'complement & signed magnitude
assign comp_Fraction_A = sign_A == 1 ? (~stickyFraction_A + 1) : stickyFraction_A;
assign comp_Fraction_B = sign_B == 1 ? (~stickyFraction_B + 1) : stickyFraction_B;
assign comp_Fraction_C = comp_Fraction_A + comp_Fraction_B;
assign mag_Fracrion_C = comp_Fraction_C[28] == 1 ? (~comp_Fraction_C + 1) : comp_Fraction_C;



assign Fraction_C_notround = mag_Fracrion_C[27:26] == 2'b01 ? mag_Fracrion_C[25:0] :
mag_Fracrion_C[27:26] == 2'b11 ? {mag_Fracrion_C[26:2] , secret_sticky} : 
mag_Fracrion_C[27:26] == 2'b10 ? {mag_Fracrion_C[26:2] , secret_sticky} :    
mag_Fracrion_C[25] == 1'b1 ? (Exponent_max > 1 ? {mag_Fracrion_C[24:0],1'b0} : mag_Fracrion_C[25:0]) : 
mag_Fracrion_C[24] == 1'b1 ? (Exponent_max > 2 ? {mag_Fracrion_C[23:0],2'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[23] == 1'b1 ?(Exponent_max > 3 ?  {mag_Fracrion_C[22:0],3'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[22] == 1'b1 ?(Exponent_max > 4 ?  {mag_Fracrion_C[21:0],4'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[21] == 1'b1 ?(Exponent_max > 5 ?  {mag_Fracrion_C[20:0],5'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[20] == 1'b1 ?(Exponent_max > 6 ?  {mag_Fracrion_C[19:0],6'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[19] == 1'b1 ?(Exponent_max > 7 ?  {mag_Fracrion_C[18:0],7'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[18] == 1'b1 ?(Exponent_max > 8 ?  {mag_Fracrion_C[17:0],8'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[17] == 1'b1 ?(Exponent_max > 9 ?  {mag_Fracrion_C[16:0],9'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[16] == 1'b1 ?(Exponent_max > 10 ?  {mag_Fracrion_C[15:0],10'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[15] == 1'b1 ?(Exponent_max > 11 ?  {mag_Fracrion_C[14:0],11'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[14] == 1'b1 ?(Exponent_max > 12 ?  {mag_Fracrion_C[13:0],12'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[13] == 1'b1 ?(Exponent_max > 13 ?  {mag_Fracrion_C[12:0],13'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[12] == 1'b1 ?(Exponent_max > 14 ?  {mag_Fracrion_C[11:0],14'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[11] == 1'b1 ?(Exponent_max > 15 ? {mag_Fracrion_C[10:0],15'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[10] == 1'b1 ?(Exponent_max > 16 ? {mag_Fracrion_C[9:0],16'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[9] == 1'b1 ?(Exponent_max > 17 ?  {mag_Fracrion_C[8:0],17'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[8] == 1'b1 ?(Exponent_max > 18 ?  {mag_Fracrion_C[7:0],18'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[7] == 1'b1 ?(Exponent_max > 19 ?  {mag_Fracrion_C[6:0],19'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[6] == 1'b1 ?(Exponent_max > 20 ?  {mag_Fracrion_C[5:0],20'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[5] == 1'b1 ?(Exponent_max > 21 ?  {mag_Fracrion_C[4:0],21'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[4] == 1'b1 ?(Exponent_max > 22 ?  {mag_Fracrion_C[3:0],22'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[3] == 1'b1 ?(Exponent_max > 23 ?  {mag_Fracrion_C[2:0],23'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[2] == 1'b1 ?(Exponent_max > 24 ?  {mag_Fracrion_C[1:0],24'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[1] == 1'b1 ?(Exponent_max > 25 ?  {mag_Fracrion_C[0],25'b0} : mag_Fracrion_C[25:0]<<(Exponent_max -1)) :
mag_Fracrion_C[0] == 1'b1 ? 26'b0 : 26'b0;

               
//////////////////////////round fraction for exponent
assign mag_Fracrion_round = mag_Fracrion_C[2] == 1'b0 ? {mag_Fracrion_C[28:3] , 3'b000} : 
mag_Fracrion_C[2:0] == 3'b111 ? {(mag_Fracrion_C[28:3] + 1) , 3'b000} : 
mag_Fracrion_C[2:0] == 3'b101 ? {(mag_Fracrion_C[28:3] + 1) , 3'b000} : 
mag_Fracrion_C[2:0] == 3'b110 ? {(mag_Fracrion_C[28:3] + 1) , 3'b000} : 
mag_Fracrion_C[3] == 1'b1 ? {(mag_Fracrion_C[28:3] + 1) , 3'b000} : {mag_Fracrion_C[28:3] , 3'b000};

////////////////////////////////////////////////////////////////////// SEF
assign Exponent_C = mag_Fracrion_round[27:26] == 2'b01 ? Exponent_max : 
mag_Fracrion_round[27:26] == 2'b11 ? Exponent_max + 1 :
mag_Fracrion_round[27:26] == 2'b10 ? Exponent_max + 1 : 
mag_Fracrion_round[25] == 1'b1 ? (Exponent_max >= 1 ? Exponent_max - 1 : 8'b0):
mag_Fracrion_round[24] == 1'b1 ? (Exponent_max >= 2 ? Exponent_max - 2 : 8'b0):
mag_Fracrion_round[23] == 1'b1 ? (Exponent_max >= 3 ? Exponent_max - 3 : 8'b0):
mag_Fracrion_round[22] == 1'b1 ? (Exponent_max >= 4 ? Exponent_max - 4 : 8'b0):
mag_Fracrion_round[21] == 1'b1 ? (Exponent_max >= 5 ? Exponent_max - 5 : 8'b0):
mag_Fracrion_round[20] == 1'b1 ? (Exponent_max >= 6 ? Exponent_max - 6 : 8'b0):
mag_Fracrion_round[19] == 1'b1 ? (Exponent_max >= 7 ? Exponent_max - 7 : 8'b0):
mag_Fracrion_round[18] == 1'b1 ? (Exponent_max >= 8 ? Exponent_max - 8 : 8'b0):
mag_Fracrion_round[17] == 1'b1 ? (Exponent_max >= 9 ? Exponent_max - 9 : 8'b0):
mag_Fracrion_round[16] == 1'b1 ? (Exponent_max >= 10 ? Exponent_max - 10 : 8'b0):
mag_Fracrion_round[15] == 1'b1 ? (Exponent_max >= 11 ? Exponent_max - 11 : 8'b0):
mag_Fracrion_round[14] == 1'b1 ? (Exponent_max >= 12 ? Exponent_max - 12 : 8'b0):
mag_Fracrion_round[13] == 1'b1 ? (Exponent_max >= 13 ? Exponent_max - 13 : 8'b0):
mag_Fracrion_round[12] == 1'b1 ? (Exponent_max >= 14 ? Exponent_max - 14 : 8'b0):
mag_Fracrion_round[11] == 1'b1 ? (Exponent_max >= 15 ? Exponent_max - 15: 8'b0):
mag_Fracrion_round[10] == 1'b1 ? (Exponent_max >= 16 ? Exponent_max - 16 : 8'b0):
mag_Fracrion_round[9] == 1'b1 ? (Exponent_max >= 17 ? Exponent_max - 17 : 8'b0):
mag_Fracrion_round[8] == 1'b1 ? (Exponent_max >= 18 ? Exponent_max - 18 : 8'b0):
mag_Fracrion_round[7] == 1'b1 ? (Exponent_max >= 19 ? Exponent_max - 19 : 8'b0):
mag_Fracrion_round[6] == 1'b1 ? (Exponent_max >= 20 ? Exponent_max - 20 : 8'b0):
mag_Fracrion_round[5] == 1'b1 ? (Exponent_max >= 21 ? Exponent_max - 21 : 8'b0):
mag_Fracrion_round[4] == 1'b1 ? (Exponent_max >= 22 ? Exponent_max - 22 : 8'b0):
mag_Fracrion_round[3] == 1'b1 ? (Exponent_max >= 23 ? Exponent_max - 23 : 8'b0):
mag_Fracrion_round[2] == 1'b1 ? (Exponent_max >= 24 ? Exponent_max - 24 : 8'b0):
mag_Fracrion_round[1] == 1'b1 ? (Exponent_max >= 25 ? Exponent_max - 25 : 8'b0):
mag_Fracrion_round[0] == 1'b1 ? (Exponent_max >= 26 ? Exponent_max - 26 : 8'b0): 8'b0;

assign Fraction_C = Fraction_C_notround[2] == 1'b0 ? Fraction_C_notround[25:3] :
Fraction_C_notround[1:0] == 2'b11 ? Fraction_C_notround[25:3] + 1 :
Fraction_C_notround[1:0] == 2'b10 ? Fraction_C_notround[25:3] + 1:
Fraction_C_notround[1:0] == 2'b01 ? Fraction_C_notround[25:3] + 1:
Fraction_C_notround[3] == 1'b0 ? Fraction_C_notround[25:3] : Fraction_C_notround[25:3] + 1;   
assign sign_C = comp_Fraction_C[28] == 1 ? 1'b1 : 1'b0; 

assign s = {sign_C,Exponent_C,Fraction_C};

endmodule
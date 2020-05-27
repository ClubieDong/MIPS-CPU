`timescale 1ns/1ps

module ALUTest;
    reg    [ 3:0] aluOp;
    reg    [31:0] din1;
    reg    [31:0] din2;
    wire   [31:0] dout;
    wire          exception;

    ALU U1
    (
        .aluOp(aluOp),
        .din1(din1),
        .din2(din2),
        .dout(dout),
        .exception(exception)
    );

    initial
    begin
        aluOp = 4'b0000; // add/addi
        din1 = 5;
        din2 = 3;
        // expect 32'h0000_0008

        #100
        aluOp = 4'b0000; // add/addi
        din1 = 32'h7FFF_FFFF;
        din2 = 32'h7FFF_FFFF;
        // expect exception

        #100
        aluOp = 4'b0001; // addu/addiu
        din1 = 32'h7FFF_FFFF;
        din2 = 32'h7FFF_FFFF;
        // expect 32'hFFFF_FFFE;

        #100
        aluOp = 4'b0010; // sub
        din1 = 5;
        din2 = 3;
        // expect 32'h0000_0002

        #100
        aluOp = 4'b0010; // sub
        din1 = 32'h7FFF_FFFF;
        din2 = 32'h8000_0000;
        // expect exception;

        #100
        aluOp = 4'b0011; // subu
        din1 = 32'h7FFF_FFFF;
        din2 = 32'h8000_0000;
        // expect 32'hFFFF_FFFF;

        #100
        aluOp = 4'b0100; // slt/slti
        din1 = 32'h7FFF_FFFF;
        din2 = 32'h8000_0000;
        // expect 32'h0000_0000;

        #100
        aluOp = 4'b0100; // slt/slti
        din1 = 32'h8000_0000;
        din2 = 32'h7FFF_FFFF;
        // expect 32'h0000_0001;

        #100
        aluOp = 4'b0101; // sltu/sltiu
        din1 = 32'hFFFF_FFFF;
        din2 = 32'h0000_0000;
        // expect 32'h0000_0000;

        #100
        aluOp = 4'b0101; // sltu/sltiu
        din1 = 32'h0000_0000;
        din2 = 32'hFFFF_FFFF;
        // expect 32'h0000_0001;

        #100
        aluOp = 4'b0110; // and/andi
        din1 = 5;
        din2 = 3;
        // expect 32'h0000_0001;

        #100
        aluOp = 4'b0111; // lui
        din1 = 32'bX;
        din2 = 32'h0000_ABCD;
        // expect 32'hABCD_0000;
        
        #100
        aluOp = 4'b1000; // nor
        din1 = 5;
        din2 = 3;
        // expect 32'hFFFF_FFF8;

        #100
        aluOp = 4'b1001; // or/ori
        din1 = 5;
        din2 = 3;
        // expect 32'h0000_0007;

        #100
        aluOp = 4'b1010; // xor/xori
        din1 = 5;
        din2 = 3;
        // expect 32'h0000_0006;

        #100
        aluOp = 4'b1011; // sllv/sll
        din1 = 32'hXXXX_XX04;
        din2 = 32'h1234_5678;
        // expect 32'h2345_6780;

        #100
        aluOp = 4'b1100; // srav/sra
        din1 = 32'hXXXX_XX04;
        din2 = 32'h1234_5678;
        // expect 32'h0123_4567;

        #100
        aluOp = 4'b1100; // srav/sra
        din1 = 32'hXXXX_XX04;
        din2 = 32'h8765_4321;
        // expect 32'hF876_5432;

        #100
        aluOp = 4'b1101; // srlv/srl
        din1 = 32'hXXXX_XX04;
        din2 = 32'h8765_4321;
        // expect 32'h0876_5432;
    end
    
endmodule

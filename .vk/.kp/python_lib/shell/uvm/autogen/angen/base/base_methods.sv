//$INSERT_HEADER_HERE
`ifndef BASE_METHODS_SV
`define BASE_METHODS_SV
//-------------------------------------------------------------------------------
// Function       : nextCRC15_D8
// Return Type    : bit[14:0]
// Arguments      : input bit [ 7 : 0 ]  data 
//                  input bit [ 14 : 0 ]  prv_crc 
// Description    : This method calculates the 15 bit CRC from the inputs
//-------------------------------------------------------------------------------
function bit [14:0] nextCRC15_D8(input bit [7:0]data,input bit [14:0]prv_crc);
  bit [14:0] crc;
  bit next_crc_bit;
  for(int itr = 0;itr < 8; itr++) begin
    next_crc_bit = prv_crc[14] ^ data[itr];
    crc[14] = prv_crc[13] ^ next_crc_bit;
    crc[13] = prv_crc[12];
    crc[12] = prv_crc[11];
    crc[11] = prv_crc[10];
    crc[10] = prv_crc[ 9] ^ next_crc_bit;
    crc[9]  = prv_crc[8];
    crc[8]  = prv_crc[7] ^ next_crc_bit;
    crc[7]  = prv_crc[6] ^ next_crc_bit;
    crc[6]  = prv_crc[5];
    crc[5]  = prv_crc[4];
    crc[4]  = prv_crc[3] ^ next_crc_bit;
    crc[3]  = prv_crc[2] ^ next_crc_bit;
    crc[2]  = prv_crc[1];
    crc[1]  = prv_crc [0];
    crc[0]  = next_crc_bit;          
    prv_crc = crc;
  end//for(int itr
  return crc;
endfunction : nextCRC15_D8

//-------------------------------------------------------------------------------
// Function       : nextCRC32_D8
// Return Type    : bit[31:0] - calculated crc
// Description    : polynomial: (0 1 2 4 5 7 8 10 11 12 16 22 23 26 32)
//                  data width: 8
//                  convention: the first serial bit is D[7]
//-------------------------------------------------------------------------------
function bit [31:0] nextCRC32_D8 ( bit [7:0] data, bit [31:0] crc);
  bit [31:0] newcrc;

  newcrc[0] = data[6] ^ data[0] ^ crc[24] ^ crc[30];
  newcrc[1] = data[7] ^ data[6] ^ data[1] ^ data[0] ^ crc[24] ^ crc[25] ^ crc[30] ^ crc[31];
  newcrc[2] = data[7] ^ data[6] ^ data[2] ^ data[1] ^ data[0] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[30] ^ crc[31];
  newcrc[3] = data[7] ^ data[3] ^ data[2] ^ data[1] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[31];
  newcrc[4] = data[6] ^ data[4] ^ data[3] ^ data[2] ^ data[0] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30];
  newcrc[5] = data[7] ^ data[6] ^ data[5] ^ data[4] ^ data[3] ^ data[1] ^ data[0] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
  newcrc[6] = data[7] ^ data[6] ^ data[5] ^ data[4] ^ data[2] ^ data[1] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
  newcrc[7] = data[7] ^ data[5] ^ data[3] ^ data[2] ^ data[0] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[31];
  newcrc[8] = data[4] ^ data[3] ^ data[1] ^ data[0] ^ crc[0] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28];
  newcrc[9] = data[5] ^ data[4] ^ data[2] ^ data[1] ^ crc[1] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29];
  newcrc[10] = data[5] ^ data[3] ^ data[2] ^ data[0] ^ crc[2] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[29];
  newcrc[11] = data[4] ^ data[3] ^ data[1] ^ data[0] ^ crc[3] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28];
  newcrc[12] = data[6] ^ data[5] ^ data[4] ^ data[2] ^ data[1] ^ data[0] ^ crc[4] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29] ^ crc[30];
  newcrc[13] = data[7] ^ data[6] ^ data[5] ^ data[3] ^ data[2] ^ data[1] ^ crc[5] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[30] ^ crc[31];
  newcrc[14] = data[7] ^ data[6] ^ data[4] ^ data[3] ^ data[2] ^ crc[6] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30] ^ crc[31];
  newcrc[15] = data[7] ^ data[5] ^ data[4] ^ data[3] ^ crc[7] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[31];
  newcrc[16] = data[5] ^ data[4] ^ data[0] ^ crc[8] ^ crc[24] ^ crc[28] ^ crc[29];
  newcrc[17] = data[6] ^ data[5] ^ data[1] ^ crc[9] ^ crc[25] ^ crc[29] ^ crc[30];
  newcrc[18] = data[7] ^ data[6] ^ data[2] ^ crc[10] ^ crc[26] ^ crc[30] ^ crc[31];
  newcrc[19] = data[7] ^ data[3] ^ crc[11] ^ crc[27] ^ crc[31];
  newcrc[20] = data[4] ^ crc[12] ^ crc[28];
  newcrc[21] = data[5] ^ crc[13] ^ crc[29];
  newcrc[22] = data[0] ^ crc[14] ^ crc[24];
  newcrc[23] = data[6] ^ data[1] ^ data[0] ^ crc[15] ^ crc[24] ^ crc[25] ^ crc[30];
  newcrc[24] = data[7] ^ data[2] ^ data[1] ^ crc[16] ^ crc[25] ^ crc[26] ^ crc[31];
  newcrc[25] = data[3] ^ data[2] ^ crc[17] ^ crc[26] ^ crc[27];
  newcrc[26] = data[6] ^ data[4] ^ data[3] ^ data[0] ^ crc[18] ^ crc[24] ^ crc[27] ^ crc[28] ^ crc[30];
  newcrc[27] = data[7] ^ data[5] ^ data[4] ^ data[1] ^ crc[19] ^ crc[25] ^ crc[28] ^ crc[29] ^ crc[31];
  newcrc[28] = data[6] ^ data[5] ^ data[2] ^ crc[20] ^ crc[26] ^ crc[29] ^ crc[30];
  newcrc[29] = data[7] ^ data[6] ^ data[3] ^ crc[21] ^ crc[27] ^ crc[30] ^ crc[31];
  newcrc[30] = data[7] ^ data[4] ^ crc[22] ^ crc[28] ^ crc[31];
  newcrc[31] = data[5] ^ crc[23] ^ crc[29];

  nextCRC32_D8 = newcrc;
endfunction

`endif//BASE_METHODS_SV
